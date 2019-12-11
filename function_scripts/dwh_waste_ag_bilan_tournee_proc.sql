CREATE OR REPLACE PROCEDURE master.dwh_waste_ag_bilan_tournee_proc
(
	in_client_name varchar
	, in_debut_date date DEFAULT null
	, in_fin_date date DEFAULT null
	, in_nb_jour int DEFAULT null
	, in_debug boolean DEFAULT false
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
	query varchar;
BEGIN
	IF in_debug
	THEN
		RAISE NOTICE 'Start';
	END IF;
	
	IF in_debut_date IS NOT NULL AND in_fin_date IS NOT NULL
	THEN
		IF in_debug
		THEN
			RAISE NOTICE 'Traitement par date.';
		END IF;
		
		query := 'DELETE FROM '||in_client_name||'.dwh_ag_bilan_commune_tournee_pap_jour
		WHERE debut_date >= '''||in_debut_date||'''
			AND debut_date < '''||in_fin_date||''';';
			
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_commune_tournee_pap_jour : Query DELETE launched : %', query;
		END IF;
		execute query;

		query := 'INSERT INTO '||in_client_name||'.dwh_ag_bilan_commune_tournee_pap_jour
		(
			insee,
			tournee_executee_id,
			asset_id,
			flux_id,
			jour,
			debut_date,
			fin_date,
			distance,
			distance_marche_arriere,
			distance_collecte,
			distance_hlp_int,
			distance_hlp_app,
			poids,
			vidage_poids_dyn,
			vidage_poids_usine,
			nb_bac,
			nb_grand_bac,
			nb_petit_bac,
			duree,
			duree_pause,
			duree_garage,
			duree_vidage,
			duree_marche_arriere,
			duree_collecte,
			duree_hlp_int,
			duree_hlp_app,
			nb_pause,
			nb_garage,
			nb_vidage,
			nb_marche_arriere,
			nb_collecte,
			nb_hlp_int,
			nb_hlp_app
		)
		SELECT
			dm_t.insee,
			ft_tt.tournee_executee_id,
			ft_tt.asset_id,
			ft_tt.flux_id,
			date_trunc(''day'', ft_tt.debut_date) AS jour,
			MIN( ft_tt.debut_date ) AS debut_date,
			MAX( ft_tt.fin_date ) AS fin_date,
			SUM( ft_tt.distance ) AS distance,
			SUM(  CASE WHEN ft_tt.marche_arriere THEN ft_tt.distance ELSE 0 END  ) AS distance_marche_arriere,
			SUM( ft_collecte.distance ) AS distance_collecte,
			SUM( ft_hlp_int.distance ) AS distance_hlp_int,
			SUM( ft_hlp_app.distance ) AS distance_hlp_app,
			SUM( ft_tt.poids ) AS poids,
			SUM( ft_v.poids_dyn ) AS vidage_poids_dyn,
			SUM( ft_v.poids_usine ) AS vidage_poids_usine,
			SUM( ft_tt.nb_bac ) AS nb_bac,
			SUM( ft_tt.nb_grand_bac ) AS nb_grand_bac,
			SUM( ft_tt.nb_petit_bac ) AS nb_petit_bac,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ) ELSE 0 END AS duree,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_p.fin_date - ft_p.debut_date ) )  ) >0 ) THEN  SUM( EXTRACT( EPOCH FROM ( ft_p.fin_date - ft_p.debut_date ) )  ) ELSE 0 END AS duree_pause,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_g.fin_date - ft_g.debut_date ) )  ) >0 ) THEN   SUM( EXTRACT( EPOCH FROM ( ft_g.fin_date - ft_g.debut_date ) ) ) ELSE 0 END AS duree_garage,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_v.fin_date - ft_v.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_v.fin_date - ft_v.debut_date ) )  )  ELSE 0 END AS duree_vidage,
			CASE WHEN ( SUM( CASE WHEN ft_tt.marche_arriere THEN EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ELSE 0 END ) >0 ) THEN SUM( CASE WHEN ft_tt.marche_arriere THEN EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ELSE 0 END )  ELSE 0 END AS duree_marche_arriere,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_collecte.fin_date - ft_collecte.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_collecte.fin_date - ft_collecte.debut_date ) ) ) ELSE 0 END AS duree_collecte,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_hlp_int.fin_date - ft_hlp_int.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_hlp_int.fin_date - ft_hlp_int.debut_date ) ) ) ELSE 0 END AS duree_hlp_int,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_hlp_app.fin_date - ft_hlp_app.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_hlp_app.fin_date - ft_hlp_app.debut_date ) ) )ELSE 0 END AS duree_hlp_app,
			COUNT( DISTINCT( ft_p.pause_ft_id ) ) AS nb_pause,
			COUNT( DISTINCT( ft_g.garage_ft_id ) ) AS nb_garage,
			COUNT( DISTINCT( ft_v.vidage_ft_id ) ) AS nb_vidage,
			SUM( CASE WHEN ft_tt.marche_arriere THEN 1 ELSE 0 END ) as nb_marche_arriere,
			COUNT( DISTINCT( ft_collecte.tache_tronc_ft_id ) ) AS nb_collecte,
			COUNT( DISTINCT( ft_hlp_int.tache_tronc_ft_id ) ) AS nb_hlp_int,
			COUNT( DISTINCT( ft_hlp_app.tache_tronc_ft_id ) ) AS nb_hlp_app
		FROM 
			'||in_client_name||'.dwh_ft_tache_tronc ft_tt
		LEFT JOIN '||in_client_name||'.dwh_dm_tronc dm_t ON ft_tt.tronc_id = dm_t.tronc_id
		LEFT JOIN '||in_client_name||'.dwh_ft_pause ft_p ON
				ft_p.tronc_id = ft_tt.tronc_id
				AND ft_p.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_p.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_p.debut_date >= '''||in_debut_date||'''
				AND ft_p.debut_date < '''||in_fin_date||'''   
		LEFT JOIN '||in_client_name||'.dwh_ft_garage ft_g ON
				ft_g.tronc_id = ft_tt.tronc_id
				AND ft_g.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_g.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_g.debut_date >= '''||in_debut_date||'''
				AND ft_g.debut_date < '''||in_fin_date||'''   
		LEFT JOIN '||in_client_name||'.dwh_ft_vidage ft_v ON
				ft_v.tronc_id = ft_tt.tronc_id
				AND ft_v.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_v.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_v.debut_date >= '''||in_debut_date||'''
				AND ft_v.debut_date < '''||in_fin_date||'''   
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_hlp_int ON
				ft_hlp_int.tronc_id = ft_tt.tronc_id
				AND ft_hlp_int.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_hlp_int.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_hlp_int.tache_type_nom IN ( ''HLP Interne'')
				AND ft_hlp_int.debut_date >= '''||in_debut_date||'''
				AND ft_hlp_int.debut_date < '''||in_fin_date||'''   
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_hlp_app ON
				ft_hlp_app.tronc_id = ft_tt.tronc_id
				AND ft_hlp_app.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_hlp_app.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_hlp_app.tache_type_nom IN ( ''HLP Approche'')
				AND ft_hlp_app.debut_date >= '''||in_debut_date||'''
				AND ft_hlp_app.debut_date < '''||in_fin_date||'''
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_collecte ON
				ft_collecte.tronc_id = ft_tt.tronc_id
				AND ft_collecte.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_collecte.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_collecte.tache_type_nom IN ( ''Collecte'')
				AND ft_collecte.debut_date >= '''||in_debut_date||'''
				AND ft_collecte.debut_date < '''||in_fin_date||'''
		WHERE
			ft_tt.debut_date >= '''||in_debut_date||'''
			AND ft_tt.debut_date < '''||in_fin_date||'''
			AND dm_t.insee IS NOT NULL
		GROUP BY
			dm_t.insee,
			ft_tt.tournee_executee_id,
			ft_tt.asset_id,
			ft_tt.flux_id,
			jour;';
		
			
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_commune_tournee_pap_jour Query INSERT launched : %', query;
		END IF;	
		EXECUTE query;
		
		query := 'DELETE FROM 
			'||in_client_name||'.dwh_ag_bilan_tournee_pap_jour
		WHERE  
			debut_date >= '''||in_debut_date||'''::date
			AND debut_date < '''||in_fin_date||'''::date;';
		
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_tournee_pap_jour Query DELETE launched : %', query;
		END IF;	
		EXECUTE query;

		query := 'INSERT INTO '||in_client_name||'.dwh_ag_bilan_tournee_pap_jour
		(
			tournee_executee_id,
			asset_id,
			flux_id,
			jour,
			debut_date,
			fin_date,
			debut_date_collecte,
			fin_date_collecte,
			distance,
			distance_marche_arriere,
			distance_collecte,
			distance_hlp_int,
			distance_hlp_app,
			poids,
			vidage_poids_dyn,
			vidage_poids_usine,
			nb_bac,
			nb_grand_bac,
			nb_petit_bac,
			duree,
			duree_pause,
			duree_garage,
			duree_vidage,
			duree_marche_arriere,
			duree_collecte,
			duree_hlp_int,
			duree_hlp_app,
			nb_pause,
			nb_garage,
			nb_vidage,
			nb_marche_arriere,
			nb_collecte,
			nb_hlp_int,
			nb_hlp_app
		)
		SELECT  
			ft_tt.tournee_executee_id,
			ft_tt.asset_id,
			ft_tt.flux_id,
			date_trunc(''day'', ft_tt.debut_date) AS jour,
			MIN( ft_tt.debut_date ) AS debut_date,
			MAX( ft_tt.fin_date ) AS fin_date,
			MIN( ft_collecte.debut_date ) AS debut_date_collecte,
			MAX( ft_collecte.fin_date ) AS fin_date_collecte,
			SUM( ft_tt.distance ) AS distance,
			SUM(  CASE WHEN ft_tt.marche_arriere THEN ft_tt.distance ELSE 0 END  ) AS distance_marche_arriere,
			SUM( ft_collecte.distance ) AS distance_collecte,
			SUM( ft_hlp_int.distance ) AS distance_hlp_int,
			SUM( ft_hlp_app.distance ) AS distance_hlp_app,
			SUM( ft_tt.poids ) AS poids,
			SUM( ft_v.poids_dyn ) AS vidage_poids_dyn,
			SUM( ft_v.poids_usine ) AS vidage_poids_usine,
			SUM( ft_tt.nb_bac ) AS nb_bac,
			SUM( ft_tt.nb_grand_bac ) AS nb_grand_bac,
			SUM( ft_tt.nb_petit_bac ) AS nb_petit_bac,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ) ELSE 0 END AS duree,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_p.fin_date - ft_p.debut_date ) )  ) >0 ) THEN  SUM( EXTRACT( EPOCH FROM ( ft_p.fin_date - ft_p.debut_date ) )  ) ELSE 0 END AS duree_pause,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_g.fin_date - ft_g.debut_date ) )  ) >0 ) THEN   SUM( EXTRACT( EPOCH FROM ( ft_g.fin_date - ft_g.debut_date ) ) ) ELSE 0 END AS duree_garage,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_v.fin_date - ft_v.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_v.fin_date - ft_v.debut_date ) )  )  ELSE 0 END AS duree_vidage,
			CASE WHEN ( SUM( CASE WHEN ft_tt.marche_arriere THEN EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ELSE 0 END ) >0 ) THEN SUM( CASE WHEN ft_tt.marche_arriere THEN EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ELSE 0 END )  ELSE 0 END AS duree_marche_arriere,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_collecte.fin_date - ft_collecte.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_collecte.fin_date - ft_collecte.debut_date ) ) ) ELSE 0 END AS duree_collecte,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_hlp_int.fin_date - ft_hlp_int.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_hlp_int.fin_date - ft_hlp_int.debut_date ) ) ) ELSE 0 END AS duree_hlp_int,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_hlp_app.fin_date - ft_hlp_app.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_hlp_app.fin_date - ft_hlp_app.debut_date ) ) )ELSE 0 END AS duree_hlp_app,
			COUNT( DISTINCT( ft_p.pause_ft_id ) ) AS nb_pause,
			COUNT( DISTINCT( ft_g.garage_ft_id ) ) AS nb_garage,
			COUNT( DISTINCT( ft_v.vidage_ft_id ) ) AS nb_vidage,
			SUM( CASE WHEN ft_tt.marche_arriere THEN 1 ELSE 0 END ) as nb_marche_arriere,
			COUNT( DISTINCT( ft_collecte.tache_tronc_ft_id ) ) AS nb_collecte,
			COUNT( DISTINCT( ft_hlp_int.tache_tronc_ft_id ) ) AS nb_hlp_int,
			COUNT( DISTINCT( ft_hlp_app.tache_tronc_ft_id ) ) AS nb_hlp_app
		FROM 
			'||in_client_name||'.dwh_ft_tache_tronc ft_tt 
		LEFT JOIN '||in_client_name||'.dwh_ft_pause ft_p ON 
				ft_p.tronc_id = ft_tt.tronc_id 
				AND ft_p.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_p.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_p.debut_date >= '''||in_debut_date||'''::date
				AND ft_p.debut_date < '''||in_fin_date||'''::date	
		LEFT JOIN '||in_client_name||'.dwh_ft_garage ft_g ON 
				ft_g.tronc_id = ft_tt.tronc_id 
				AND ft_g.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_g.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_g.debut_date >= '''||in_debut_date||'''::date
				AND ft_g.debut_date < '''||in_fin_date||'''::date	
		LEFT JOIN '||in_client_name||'.dwh_ft_vidage ft_v ON 
				ft_v.tronc_id = ft_tt.tronc_id 
				AND ft_v.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_v.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_v.debut_date >= '''||in_debut_date||'''::date
				AND ft_v.debut_date < '''||in_fin_date||'''::date	
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_hlp_int ON 
				ft_hlp_int.tronc_id = ft_tt.tronc_id 
				AND ft_hlp_int.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_hlp_int.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_hlp_int.tache_type_nom IN ( ''HLP Interne'')
				AND ft_hlp_int.debut_date >= '''||in_debut_date||'''::date
				AND ft_hlp_int.debut_date < '''||in_fin_date||'''::date	
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_hlp_app ON 
				ft_hlp_app.tronc_id = ft_tt.tronc_id 
				AND ft_hlp_app.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_hlp_app.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_hlp_app.tache_type_nom IN ( ''HLP Approche'')
				AND ft_hlp_app.debut_date >= '''||in_debut_date||'''::date	
				AND ft_hlp_app.debut_date < '''||in_fin_date||'''::date
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_collecte ON 
				ft_collecte.tronc_id = ft_tt.tronc_id 
				AND ft_collecte.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_collecte.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_collecte.tache_type_nom IN ( ''Collecte'')
				AND ft_collecte.debut_date >= '''||in_debut_date||'''::date
				AND ft_collecte.debut_date < '''||in_fin_date||'''::date
		WHERE  
			ft_tt.debut_date >= '''||in_debut_date||'''::date
			AND ft_tt.debut_date < '''||in_fin_date||'''::date
		GROUP BY 
			ft_tt.tournee_executee_id,
			ft_tt.asset_id,
			ft_tt.flux_id,
			jour;';
		EXECUTE query;		
		
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_tournee_pap_jour Query INSERT launched : %', query;
		END IF;	
		EXECUTE query;

		query := 'UPDATE '||in_client_name||'.dwh_ag_bilan_tournee_pap_jour
			SET poids_heure = ( (poids/1000) / (duree*24) )
				, bac_heure = ( nb_bac / (duree*24) )
		WHERE debut_date >= '''||in_debut_date||'''::date
			AND debut_date < '''||in_fin_date||'''::date
			AND duree > 0;';
		
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_tournee_pap_jour Query UPDATE launched : %', query;
		END IF;			
		EXECUTE query;		
			
	ELSEIF in_nb_jour IS NOT NULL
	THEN
		IF in_debug
		THEN
			RAISE NOTICE 'Traitement par jour.';
		END IF;
		
		query := 'DELETE FROM '||in_client_name||'.dwh_ag_bilan_commune_tournee_pap_jour
		WHERE debut_date >= current_date - interval '''||in_nb_jour||' days'';';
		
			
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_commune_tournee_pap_jour : Query DELETE launched : %', query;
		END IF;
		EXECUTE query;

		query := 'INSERT INTO '||in_client_name||'.dwh_ag_bilan_commune_tournee_pap_jour
		(
			insee,
			tournee_executee_id,
			asset_id,
			flux_id,
			jour,
			debut_date,
			fin_date,
			distance,
			distance_marche_arriere,
			distance_collecte,
			distance_hlp_int,
			distance_hlp_app,
			poids,
			vidage_poids_dyn,
			vidage_poids_usine,
			nb_bac,
			nb_grand_bac,
			nb_petit_bac,
			duree,
			duree_pause,
			duree_garage,
			duree_vidage,
			duree_marche_arriere,
			duree_collecte,
			duree_hlp_int,
			duree_hlp_app,
			nb_pause,
			nb_garage,
			nb_vidage,
			nb_marche_arriere,
			nb_collecte,
			nb_hlp_int,
			nb_hlp_app
		)
		SELECT
			dm_t.insee,
			ft_tt.tournee_executee_id,
			ft_tt.asset_id,
			ft_tt.flux_id,
			date_trunc(''day'', ft_tt.debut_date) AS jour,
			MIN( ft_tt.debut_date ) AS debut_date,
			MAX( ft_tt.fin_date ) AS fin_date,
			SUM( ft_tt.distance ) AS distance,
			SUM(  CASE WHEN ft_tt.marche_arriere THEN ft_tt.distance ELSE 0 END  ) AS distance_marche_arriere,
			SUM( ft_collecte.distance ) AS distance_collecte,
			SUM( ft_hlp_int.distance ) AS distance_hlp_int,
			SUM( ft_hlp_app.distance ) AS distance_hlp_app,
			SUM( ft_tt.poids ) AS poids,
			SUM( ft_v.poids_dyn ) AS vidage_poids_dyn,
			SUM( ft_v.poids_usine ) AS vidage_poids_usine,
			SUM( ft_tt.nb_bac ) AS nb_bac,
			SUM( ft_tt.nb_grand_bac ) AS nb_grand_bac,
			SUM( ft_tt.nb_petit_bac ) AS nb_petit_bac,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ) ELSE 0 END AS duree,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_p.fin_date - ft_p.debut_date ) )  ) >0 ) THEN  SUM( EXTRACT( EPOCH FROM ( ft_p.fin_date - ft_p.debut_date ) )  ) ELSE 0 END AS duree_pause,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_g.fin_date - ft_g.debut_date ) )  ) >0 ) THEN   SUM( EXTRACT( EPOCH FROM ( ft_g.fin_date - ft_g.debut_date ) ) ) ELSE 0 END AS duree_garage,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_v.fin_date - ft_v.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_v.fin_date - ft_v.debut_date ) )  )  ELSE 0 END AS duree_vidage,
			CASE WHEN ( SUM( CASE WHEN ft_tt.marche_arriere THEN EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ELSE 0 END ) >0 ) THEN SUM( CASE WHEN ft_tt.marche_arriere THEN EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ELSE 0 END )  ELSE 0 END AS duree_marche_arriere,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_collecte.fin_date - ft_collecte.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_collecte.fin_date - ft_collecte.debut_date ) ) ) ELSE 0 END AS duree_collecte,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_hlp_int.fin_date - ft_hlp_int.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_hlp_int.fin_date - ft_hlp_int.debut_date ) ) ) ELSE 0 END AS duree_hlp_int,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_hlp_app.fin_date - ft_hlp_app.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_hlp_app.fin_date - ft_hlp_app.debut_date ) ) )ELSE 0 END AS duree_hlp_app,
			COUNT( DISTINCT( ft_p.pause_ft_id ) ) AS nb_pause,
			COUNT( DISTINCT( ft_g.garage_ft_id ) ) AS nb_garage,
			COUNT( DISTINCT( ft_v.vidage_ft_id ) ) AS nb_vidage,
			SUM( CASE WHEN ft_tt.marche_arriere THEN 1 ELSE 0 END ) as nb_marche_arriere,
			COUNT( DISTINCT( ft_collecte.tache_tronc_ft_id ) ) AS nb_collecte,
			COUNT( DISTINCT( ft_hlp_int.tache_tronc_ft_id ) ) AS nb_hlp_int,
			COUNT( DISTINCT( ft_hlp_app.tache_tronc_ft_id ) ) AS nb_hlp_app
		FROM 
			'||in_client_name||'.dwh_ft_tache_tronc ft_tt
		LEFT JOIN '||in_client_name||'.dwh_dm_tronc dm_t ON ft_tt.tronc_id = dm_t.tronc_id
		LEFT JOIN '||in_client_name||'.dwh_ft_pause ft_p ON
				ft_p.tronc_id = ft_tt.tronc_id
				AND ft_p.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_p.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_p.debut_date >= current_date - interval '''||in_nb_jour||' days''
		LEFT JOIN '||in_client_name||'.dwh_ft_garage ft_g ON
				ft_g.tronc_id = ft_tt.tronc_id
				AND ft_g.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_g.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_g.debut_date >= current_date - interval '''||in_nb_jour||' days''
		LEFT JOIN '||in_client_name||'.dwh_ft_vidage ft_v ON
				ft_v.tronc_id = ft_tt.tronc_id
				AND ft_v.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_v.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_v.debut_date >= current_date - interval '''||in_nb_jour||' days''
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_hlp_int ON
				ft_hlp_int.tronc_id = ft_tt.tronc_id
				AND ft_hlp_int.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_hlp_int.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_hlp_int.tache_type_nom IN ( ''HLP Interne'')
				AND ft_hlp_int.debut_date >= current_date - interval '''||in_nb_jour||' days''  
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_hlp_app ON
				ft_hlp_app.tronc_id = ft_tt.tronc_id
				AND ft_hlp_app.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_hlp_app.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_hlp_app.tache_type_nom IN ( ''HLP Approche'')
				AND ft_hlp_app.debut_date >= current_date - interval '''||in_nb_jour||' days''
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_collecte ON
				ft_collecte.tronc_id = ft_tt.tronc_id
				AND ft_collecte.tournee_executee_id = ft_tt.tournee_executee_id
				AND date_trunc(''day'', ft_collecte.debut_date) = date_trunc(''day'', ft_tt.debut_date)
				AND ft_collecte.tache_type_nom IN ( ''Collecte'')
				AND ft_collecte.debut_date >= current_date - interval '''||in_nb_jour||' days''
		WHERE
			ft_tt.debut_date >= current_date - interval '''||in_nb_jour||' days''
			AND dm_t.insee IS NOT NULL
		GROUP BY
			dm_t.insee,
			ft_tt.tournee_executee_id,
			ft_tt.asset_id,
			ft_tt.flux_id,
			jour;';
			
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_commune_tournee_pap_jour : Query INSERT launched : %', query;
		END IF;
		EXECUTE query;
		
		query := 'DELETE FROM 
			'||in_client_name||'.dwh_ag_bilan_tournee_pap_jour
		WHERE  
			debut_date >= current_date - interval '''||in_nb_jour||' days'';';
		
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_tournee_pap_jour : Query DELETE launched : %', query;
		END IF;
		EXECUTE query;

		query := 'INSERT INTO '||in_client_name||'.dwh_ag_bilan_tournee_pap_jour
		(
			tournee_executee_id,
			asset_id,
			flux_id,
			jour,
			debut_date,
			fin_date,
			debut_date_collecte,
			fin_date_collecte,
			distance,
			distance_marche_arriere,
			distance_collecte,
			distance_hlp_int,
			distance_hlp_app,
			poids,
			vidage_poids_dyn,
			vidage_poids_usine,
			nb_bac,
			nb_grand_bac,
			nb_petit_bac,
			duree,
			duree_pause,
			duree_garage,
			duree_vidage,
			duree_marche_arriere,
			duree_collecte,
			duree_hlp_int,
			duree_hlp_app,
			nb_pause,
			nb_garage,
			nb_vidage,
			nb_marche_arriere,
			nb_collecte,
			nb_hlp_int,
			nb_hlp_app
		)
		SELECT  
			ft_tt.tournee_executee_id,
			ft_tt.asset_id,
			ft_tt.flux_id,
			date_trunc(''day'', ft_tt.debut_date) AS jour,
			MIN( ft_tt.debut_date ) AS debut_date,
			MAX( ft_tt.fin_date ) AS fin_date,
			MIN( ft_collecte.debut_date ) AS debut_date_collecte,
			MAX( ft_collecte.fin_date ) AS fin_date_collecte,
			SUM( ft_tt.distance ) AS distance,
			SUM(  CASE WHEN ft_tt.marche_arriere THEN ft_tt.distance ELSE 0 END  ) AS distance_marche_arriere,
			SUM( ft_collecte.distance ) AS distance_collecte,
			SUM( ft_hlp_int.distance ) AS distance_hlp_int,
			SUM( ft_hlp_app.distance ) AS distance_hlp_app,
			SUM( ft_tt.poids ) AS poids,
			SUM( ft_v.poids_dyn ) AS vidage_poids_dyn,
			SUM( ft_v.poids_usine ) AS vidage_poids_usine,
			SUM( ft_tt.nb_bac ) AS nb_bac,
			SUM( ft_tt.nb_grand_bac ) AS nb_grand_bac,
			SUM( ft_tt.nb_petit_bac ) AS nb_petit_bac,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ) ELSE 0 END AS duree,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_p.fin_date - ft_p.debut_date ) )  ) >0 ) THEN  SUM( EXTRACT( EPOCH FROM ( ft_p.fin_date - ft_p.debut_date ) )  ) ELSE 0 END AS duree_pause,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_g.fin_date - ft_g.debut_date ) )  ) >0 ) THEN   SUM( EXTRACT( EPOCH FROM ( ft_g.fin_date - ft_g.debut_date ) ) ) ELSE 0 END AS duree_garage,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_v.fin_date - ft_v.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_v.fin_date - ft_v.debut_date ) )  )  ELSE 0 END AS duree_vidage,
			CASE WHEN ( SUM( CASE WHEN ft_tt.marche_arriere THEN EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ELSE 0 END ) >0 ) THEN SUM( CASE WHEN ft_tt.marche_arriere THEN EXTRACT( EPOCH FROM ( ft_tt.fin_date - ft_tt.debut_date ) ) ELSE 0 END )  ELSE 0 END AS duree_marche_arriere,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_collecte.fin_date - ft_collecte.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_collecte.fin_date - ft_collecte.debut_date ) ) ) ELSE 0 END AS duree_collecte,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_hlp_int.fin_date - ft_hlp_int.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_hlp_int.fin_date - ft_hlp_int.debut_date ) ) ) ELSE 0 END AS duree_hlp_int,
			CASE WHEN ( SUM( EXTRACT( EPOCH FROM ( ft_hlp_app.fin_date - ft_hlp_app.debut_date ) )  ) >0 ) THEN SUM( EXTRACT( EPOCH FROM ( ft_hlp_app.fin_date - ft_hlp_app.debut_date ) ) )ELSE 0 END AS duree_hlp_app,
			COUNT( DISTINCT( ft_p.pause_ft_id ) ) AS nb_pause,
			COUNT( DISTINCT( ft_g.garage_ft_id ) ) AS nb_garage,
			COUNT( DISTINCT( ft_v.vidage_ft_id ) ) AS nb_vidage,
			SUM( CASE WHEN ft_tt.marche_arriere THEN 1 ELSE 0 END ) as nb_marche_arriere,
			COUNT( DISTINCT( ft_collecte.tache_tronc_ft_id ) ) AS nb_collecte,
			COUNT( DISTINCT( ft_hlp_int.tache_tronc_ft_id ) ) AS nb_hlp_int,
			COUNT( DISTINCT( ft_hlp_app.tache_tronc_ft_id ) ) AS nb_hlp_app
		FROM 
			'||in_client_name||'.dwh_ft_tache_tronc ft_tt 
		LEFT JOIN '||in_client_name||'.dwh_ft_pause ft_p ON 
				ft_p.tronc_id = ft_tt.tronc_id 
				AND ft_p.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_p.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_p.debut_date >= current_date - interval '''||in_nb_jour||' days''	
		LEFT JOIN '||in_client_name||'.dwh_ft_garage ft_g ON 
				ft_g.tronc_id = ft_tt.tronc_id 
				AND ft_g.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_g.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_g.debut_date >= current_date - interval '''||in_nb_jour||' days''
		LEFT JOIN '||in_client_name||'.dwh_ft_vidage ft_v ON 
				ft_v.tronc_id = ft_tt.tronc_id 
				AND ft_v.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_v.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_v.debut_date >= current_date - interval '''||in_nb_jour||' days''	
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_hlp_int ON 
				ft_hlp_int.tronc_id = ft_tt.tronc_id 
				AND ft_hlp_int.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_hlp_int.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_hlp_int.tache_type_nom IN ( ''HLP Interne'')
				AND ft_hlp_int.debut_date >= current_date - interval '''||in_nb_jour||' days''	
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_hlp_app ON 
				ft_hlp_app.tronc_id = ft_tt.tronc_id 
				AND ft_hlp_app.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_hlp_app.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_hlp_app.tache_type_nom IN ( ''HLP Approche'')
				AND ft_hlp_app.debut_date >= current_date - interval '''||in_nb_jour||' days''
		LEFT JOIN '||in_client_name||'.dwh_ft_tache_tronc ft_collecte ON 
				ft_collecte.tronc_id = ft_tt.tronc_id 
				AND ft_collecte.tournee_executee_id = ft_tt.tournee_executee_id 
				AND date_trunc(''day'', ft_collecte.debut_date) = date_trunc(''day'', ft_tt.debut_date) 
				AND ft_collecte.tache_type_nom IN ( ''Collecte'')
				AND ft_collecte.debut_date >= current_date - interval '''||in_nb_jour||' days''
		WHERE  
			ft_tt.debut_date >= current_date - interval '''||in_nb_jour||' days''
		GROUP BY 
			ft_tt.tournee_executee_id,
			ft_tt.asset_id,
			ft_tt.flux_id,
			jour;';
		
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_tournee_pap_jour : Query INSERT launched : %', query;
		END IF;
		EXECUTE query;
	
		query := 'UPDATE '||in_client_name||'.dwh_ag_bilan_tournee_pap_jour
			SET poids_heure = ( (poids/1000) / (duree*24) )
				, bac_heure = ( nb_bac / (duree*24) )
		WHERE debut_date >= current_date - interval '''||in_nb_jour||' days''
			AND duree > 0;';
		
		IF in_debug
		THEN
			RAISE NOTICE 'dwh_ag_bilan_tournee_pap_jour : Query UPDATE launched : %', query;
		END IF;
		EXECUTE query;
	ELSE 
		RAISE EXCEPTION 'Soit les deux dates doivent être renseignées, soit le nombre de jours.';
	END IF;	
END;
$procedure$;