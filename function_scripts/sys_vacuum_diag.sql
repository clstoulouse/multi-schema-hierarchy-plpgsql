CREATE OR REPLACE FUNCTION common.sys_vacuum_diag(in_schema_name varchar)
RETURNS varchar
LANGUAGE plpgsql
AS $function$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est d'avoir plus de maîtrise sur les VACUUM et ANALYZE
-- Sortie du script :
-- - la liste des tables ayant été VACUUM
-- - la liste des tables n'ayant, à tord, pas été VACUUM ainsi que la raison
-- - la liste des tables ayant été ANALYZE
--
-- Conditions pour lancement d'un VACUUM manuel sur une table :
-- - vacuum_running = false
-- - AND dead_percentage > 25
-- - AND (nb_sec_from_last_vacuum IS NULL OR nb_sec_from_last_vacuum > 432 000 (5 jours)
-- - AND table_size > 100 M
--
-- Conditions pour le lancement d'un ANALYZE
-- - à la suite d'un VACUUM
-- - OR (nb_sec_from_last_analyze > 2 592 000 (30 jours)
-- Origines : PostgreSQL v11 | 26/02/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			26/02/2019		Création
--	JPI			16/04/2019		La table de résultat doit être persistante
--	JPI			17/04/2019		Grosse refonte. Renvoit maintenant le script a exécuter.
--
---------------------------------------------------------------------------------------------------------------
DECLARE
	res_1 varchar;
	res_2 varchar;
BEGIN
	-- Construction de la table de log
	CREATE TABLE IF NOT EXISTS common.vacuum_script_results
	(
		id serial primary key
		, date_sys_vacuum_diag timestamp
		, schema_name character varying
		, table_name character varying
		, analyze_status boolean
		, vacuum_status boolean
		, commentaries character varying
	);
	
	-- Tous les vacuum nécessaires
	WITH cte AS
	(
		SELECT 
			nspname as schema_name
			, C.relname as table_name
			, S.n_live_tup
			, S.n_dead_tup
			, 	CASE 
					WHEN (S.n_live_tup+S.n_dead_tup) <> 0 
						THEN ((S.n_dead_tup * 100) / (S.n_live_tup+S.n_dead_tup)) 
						ELSE 0 
				END as dead_percentage
			, S.last_vacuum
			, S.last_analyze
			, ROUND(CAST(CAST(extract(epoch from (current_timestamp - S.last_analyze)) as character varying) as numeric), 0) as nb_sec_from_last_analyze
			, ROUND(CAST(CAST(extract(epoch from (current_timestamp - S.last_vacuum)) as character varying) as numeric), 0) as nb_sec_from_last_vacuum
			, pg_table_size(C.oid) AS table_size
			, CASE WHEN V.pid IS NOT NULL THEN true ELSE false END as vacuum_running
			, CASE
				WHEN L.mode = 'ShareUpdateExclusiveLock'
					THEN 'VACUUM, ANALYZE, CREATE INDEX CONCURRENTLY, CREATE STATISTICS, ALTER TABLE. L''une de ces étapes est en cours.'
				WHEN L.mode = 'ShareLock'
					THEN 'CREATE INDEX en cours'
				WHEN L.mode = 'ShareRowExclusiveLock'
					THEN 'CREATE COLLATION, CREATE TRIGGER, ALTER TABLE. L''une de ces étapes est en cours'
				WHEN L.mode = 'ExclusiveLock'
					THEN 'REFRESH MATERIALIZED VIEW CONCURRENTLY en cours'
				WHEN L.mode = 'AccessExclusiveLock'
					THEN 'DROP TABLE, TRUNCATE, REINDEX, CLUSTER, VACUUM FULL, and REFRESH MATERIALIZED VIEW (without CONCURRENTLY). L''une de ces étapes est en cours.'
			END as lock_reason
			, ROUND(CAST(CAST(extract(epoch from (current_timestamp - ST.query_start)) as character varying) as numeric), 0) as nb_sec_from_query_start
			, ST.state as state_of_running_query
		FROM pg_class C
			INNER JOIN pg_namespace N 
				ON N.oid = C.relnamespace
			LEFT OUTER JOIN pg_stat_user_tables S			-- La vue système reprenant les statistiques des tables définies par les utilisateurs
				ON S.relname = C.relname
				and s.schemaname = N.nspname
			LEFT OUTER JOIN pg_stat_progress_vacuum V 		-- La vue système reprenant les statistiques reprenant l'état courant des vacuum
				ON V.relid = S.relid
			LEFT OUTER JOIN pg_locks L 						-- Les locks en cours
				ON L.relation = C.oid
			LEFT OUTER JOIN pg_inherits I ON 				-- Les héritages pour mener à la vue des statistiques courantes d'utilisation.
				C.oid = I.inhrelid
			LEFT OUTER JOIN pg_class CM ON 
				CM.oid = I.inhparent
			LEFT OUTER JOIN pg_stat_activity ST 			-- La vue des statistiques courantes d'utilisation
				ON ST.query LIKE '%'||C.relname||'%' 
					OR ST.query LIKE '%'||CM.relname||'%' 
		WHERE N.nspname = in_schema_name
			AND C.relkind = 'r'
	)
	SELECT string_agg(
		'VACUUM ANALYZE '||cte.schema_name||'.'||cte.table_name||';'||chr(10)||
		'INSERT INTO common.vacuum_script_results
		(
			date_sys_vacuum_diag
			, schema_name
			, table_name
			, analyze_status
			, vacuum_status
			, commentaries
		)
		VALUES
		(
			now()
			, '''||cte.schema_name||'''
			, '''||cte.table_name||'''
			, true
			, true
			, '||
				coalesce(
				CASE 
					WHEN (cte.vacuum_running) THEN 'Un VACUUM est déjà en cours sur cette table.'
					WHEN (cte.lock_reason IS NOT NULL) THEN cte.lock_reason
					WHEN (cte.state_of_running_query LIKE '%idle%')	THEN 'Une requête occupe déjà cette table depuis : '|| cast(cte.nb_sec_from_query_start as varchar)
				 end, 'null')
			||'
		);'
		, chr(10) order by cte.schema_name, cte.table_name) INTO res_1
	FROM cte
	WHERE cte.dead_percentage > 25
		AND (cte.nb_sec_from_last_vacuum IS NULL OR cte.nb_sec_from_last_vacuum > 432000)
		AND cte.table_size > 104570880 
		AND cte.vacuum_running = false
		AND cte.lock_reason IS NULL
		AND (cte.state_of_running_query IS NULL OR cte.state_of_running_query NOT LIKE '%idle%');
		
		
	-- Les ANALYZE seuls
	WITH cte AS
	(
		SELECT 
			nspname as schema_name
			, C.relname as table_name
			, S.n_live_tup
			, S.n_dead_tup
			, CASE WHEN (S.n_live_tup+S.n_dead_tup) <> 0 THEN ((S.n_dead_tup * 100) / (S.n_live_tup+S.n_dead_tup)) ELSE 0 END as dead_percentage
			, S.last_vacuum
			, S.last_analyze
			, ROUND(CAST(CAST(extract(epoch from (current_timestamp - S.last_analyze)) as character varying) as numeric), 0) as nb_sec_from_last_analyze
			, ROUND(CAST(CAST(extract(epoch from (current_timestamp - S.last_vacuum)) as character varying) as numeric), 0) as nb_sec_from_last_vacuum
			, pg_table_size(C.oid) AS table_size
			, CASE WHEN V.pid IS NOT NULL THEN true ELSE false END as vacuum_running
			, CASE
				WHEN L.mode = 'ShareUpdateExclusiveLock'
					THEN 'VACUUM, ANALYZE, CREATE INDEX CONCURRENTLY, CREATE STATISTICS, ALTER TABLE. L''une de ces étapes est en cours.'
				WHEN L.mode = 'ShareLock'
					THEN 'CREATE INDEX en cours'
				WHEN L.mode = 'ShareRowExclusiveLock'
					THEN 'CREATE COLLATION, CREATE TRIGGER, ALTER TABLE. L''une de ces étapes est en cours'
				WHEN L.mode = 'ExclusiveLock'
					THEN 'REFRESH MATERIALIZED VIEW CONCURRENTLY en cours'
				WHEN L.mode = 'AccessExclusiveLock'
					THEN 'DROP TABLE, TRUNCATE, REINDEX, CLUSTER, VACUUM FULL, and REFRESH MATERIALIZED VIEW (without CONCURRENTLY). L''une de ces étapes est en cours.'
			END as lock_reason
			, ROUND(CAST(CAST(extract(epoch from (current_timestamp - ST.query_start)) as character varying) as numeric), 0) as nb_sec_from_query_start
			, ST.state as state_of_running_query
		FROM pg_class C
			INNER JOIN pg_namespace N 
				ON N.oid = C.relnamespace
			LEFT OUTER JOIN pg_stat_user_tables S
				ON S.relname = C.relname
				and s.schemaname = N.nspname
			LEFT OUTER JOIN pg_stat_progress_vacuum V 
				ON V.relid = S.relid
			LEFT OUTER JOIN pg_locks L 
				ON L.relation = C.oid
			LEFT OUTER JOIN pg_inherits I ON 
				C.oid = I.inhrelid
			LEFT OUTER JOIN pg_class CM ON 
				CM.oid = I.inhparent
			LEFT OUTER JOIN pg_stat_activity ST 
				ON ST.query LIKE '%'||C.relname||'%' 
					OR ST.query LIKE '%'||CM.relname||'%' 
		WHERE N.nspname = in_schema_name
			AND C.relkind = 'r'
	)
	SELECT string_agg('ANALYZE '||cte.schema_name||'.'||cte.table_name||';'||chr(10)||
		'INSERT INTO common.vacuum_script_results
		(
			date_sys_vacuum_diag
			, schema_name
			, table_name
			, analyze_status
			, vacuum_status
			, commentaries
		)
		VALUES
		(
			now()
			, '''||cte.schema_name||'''
			, '''||cte.table_name||'''
			, true
			, false
			, '||
				coalesce(
				CASE 
					WHEN (cte.vacuum_running) THEN 'Un VACUUM est déjà en cours sur cette table.'
					WHEN (cte.lock_reason IS NOT NULL) THEN cte.lock_reason
					WHEN (cte.state_of_running_query LIKE '%idle%')	THEN 'Une requête occupe déjà cette table depuis : '|| cast(cte.nb_sec_from_query_start as varchar)
				 end, 'null')
			||'
		);', chr(10) order by cte.schema_name, cte.table_name) INTO res_2
	FROM cte
	WHERE (cte.dead_percentage < 25
		OR (cte.nb_sec_from_last_vacuum IS NOT NULL AND cte.nb_sec_from_last_vacuum < 432000)
		OR cte.table_size < 104570880 
		OR cte.vacuum_running = true
		OR cte.lock_reason IS NOT NULL
		OR (cte.state_of_running_query IS NOT NULL AND cte.state_of_running_query LIKE '%idle%'))
		AND (cte.nb_sec_from_last_analyze IS NULL OR cte.nb_sec_from_last_analyze > 2592000)
		AND (cte.schema_name, cte.table_name) NOT IN (SELECT T.schema_name, T.table_name FROM common.vacuum_script_results T WHERE T.analyze_status = true);
		
	RETURN COALESCE(res_1, '')||chr(10)||COALESCE(res_2, '');
END;
$function$;