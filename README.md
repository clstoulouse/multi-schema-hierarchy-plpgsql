# Multi Schema Hierarchy PGPSQL Project

@author <smartin@groupcls.com>: Project manager & Product owner  
@author <jaisus666@hotmail.fr>: Software architect, Developer  

>How to read this file? 
Use a markdown reader: 
plugins [chrome](https://chrome.google.com/webstore/detail/markdown-preview/jmchmkecamhbiokiopfpnfgbidieafmd?utm_source=chrome-app-launcher-info-dialog) exists (Once installed in Chrome, open URL chrome://extensions/, and check "Markdown Preview"/Authorise access to file URL.),
or for [firefox](https://addons.mozilla.org/fr/firefox/addon/markdown-viewer/)  (anchor tags do not work)
and also plugin for [notepadd++](https://github.com/Edditoria/markdown_npp_zenburn).  
>Be careful: Markdown format has issue while rendering underscore "\_" character which can lead to bad variable name or path.  

## Summary

* [Overview](#Overview)
* [Installation](#Installation)
* [Technical presentation](#Architecture)
* [Recommandations](#Recommandations)

## <a name="Overview">Overview</a>

These scripts are dedicated to automatization of schema's replication.
In a context where you have a master schema in a PostgreSQL database, and you want to ensure that all other schemas are the exact replication of this master, you need to have each object structured and to control at each single change that everything is consistant.
Then, these scripts overwatch the database to automatically:

* Automatically create a new child schema using the current structure of the master schema
* Harmonize names for each object
* Deploy each change made on the master schema
* Cancel each change made on a child schema if there is no corresponding change in the master schema

A technical schema, names 'common', is used to store common functions.
Once the scripts are [installed](#Installation), changes will be automatically detected and the related action automatically launched.

## <a name="Installation">Installation</a>  

A scrit is dedicate to deploy a brand new environment : *init\_all.sh*
This script needs to be in a folder that contains the following subfolders:

* DWH_WASTE_TU : contains unit tests
* waste_dwh_script : contains multi-schema management scripts

You will be prompted to detail the server where the database will be created and relate authentication details.

The script will:

* Cretae / modify the given database with all necessary components
* Launch automated tests to ensure everything will run correctly

At this stage, it is strongly recommand to **never launch this scritp on an existing database** unless you intend to delete it (wich will also remove all data without saving them) and create it again.

## <a name="Architecture">Architecture</a>  

### General presentation

Two main schemas are created:

* *common*, a technical schema where all common features are stored
* *master*, the master schema is the single one where changes are supposed to be done.

Dedicated roles are also automatically created:

* A *Developper role* with the following access:
  * Create, update, delete tables in *master* schema
  * Read data in *master* schema
  * Create and delete indexes in *master* schema
  * Create primary and foreign keys in *master* schema
  * Create, update, delete sequences in *master* schema
  * It is not possible for a developper to make changes on a child schema, nor update data in a child schema
* A *Dashboard role* able to read data in the *master* schema and all children schema
* A *Administrator role*, which is NOT *postgres*, to allow to modify the whole system for maintenance purposes. This role is the only one with the ability to create and delete child schema.
* *reader_all*: read-only access to the *master* schema and all children
* *writer_all*: create, read, update, delete access to the *master* schema and all children

Each time a new *child* schema is created, it comes with predefined roles (password = login):

* *reader*: read-only access to the related schema
* *writer*: access to create, read, update and delete data in the related schema

The scripts create procedures and triggers to manage child schemas' creation (and deletion) and ensure each child has always the same structure than the *master* schema.

### Technical details

The scripts are developped and tested for PostgreSQL 11.x databases.
In the *common* schema, a table named *Customer* is dedicated to store each child name. These scripts have been developed to manage customer data and this solution requires that one schema is created for each single client.

When a primary key is defined (in the *master* schema) and when it is base on a single integer column, then a sequence will be created in the *master* schema. This sequence will be the default value for this primary key. Thus, due to the fact that, in PostgreSQL, a sequence is [non-transactional](https://www.postgresql.org/docs/current/functions-sequence.html), the unicity of the key is guaranted even across child tables that will be created using this sequence for thei primary keys.
Therefore, **IT IS STRONGLY RECOMMANDED to create primary keys on single interger columns**.  

Some [EVENT TRIGGERS](https://www.postgresql.org/docs/current/event-triggers.html) will be created on the following actions: *CREATE TABLE*, *ALTER TABLE*, *DROP TABLE*, *CREATE INDEX*. These triggers will call necessary stored procedures to ensure each action made on the *master* schema will be reproduced on each *child* schema.

### Scripts description

Scripts are splitted in several categories:

* [Procedures](#Procedures): commands launched manually for a single action
* [Triggers](#Triggers): commands launched when specific events occur
* [Scripts](#Scripts): commands launched by procedures or triggers to perform unitary or global actions
* [Tools](#Tools) : commands created for supervision, administration and maintenance purposes

Each of them is described hereafter.

#### <a name="Procedures">Procedures</a>

The next procedures will be launched individually to perform some specific actions.

##### Child schema creation (create\_new\_client.sql)

To call this procedure, use the following SQL command:
`call common.create_new_client('[nom_client]', '[password]');`  

This is supposed to be **the only way to create a new schema**.  

It performs the following actions:

* If table common.dwh_dm_client does not exists, it is created
* Create a new ligne in common.client (after an included unicity check on the schema's name)
* Create a new child schema using the given name
* Create all tables and objects acoording to the current *master* structure
  * Primary keys are named according this rule : 'pk_[nom_table]_[nom_client]'
  * Foreign keys are named according this rule : 'fk_[nom_table_support_contrainte]_[nom_table_référencée]_[nom_client]_[numéro_itéré]'
  * Reader role is named : 'reader_[nom_client]'; his default schema is the new created one and it comes with USAGE privilege on the schema and SELECT privilege on all tables within the schema
  * Writer role is named : 'writer_[nom_client]'; his default schema is the new created one and it comes with the following privileges:
    * USAGE privilege on the schema
    * SELECT privilege on all tables within the schema
    * USAGE privilege on primary key sequences if any
    * INSERT and UPDATE privileges on all columns within the schema, except primary keys defined as single integer columns (technically speeking, primary ky with based on than 2 columns)

##### Child schema deletion (**Irreversible action**)

To call this procedure, use the following SQL command:
`call common.drop_client('[nom_client]');`  

This is supposed to be **the only way to delete a schema**.  

It performs the following actions:

* Check whether the schema actually exists
* Delete cascade the schema
* Delete related roles
* Delete related line in table common.client

#### <a name="Triggers">Triggers</a>

Several [EVENT TRIGGERS](https://www.postgresql.org/docs/current/event-triggers.html) are created to perform some actions when changes occur in *master* schema. They mainly launch stored procedures.
These triggers are listed hereafter.

##### Create table (in *master* schema)

This is performed using the standard CREATE TABLE SQL statement. It launches *ddl\_trigger\_create\_table\_fct* event trigger which performs the following actions:

* Create table with the same characteristics in each *child* schema
* Provide roles with privileges on the table according to roles definition

Caution: **NEVER USE A CUSTOMER NAME OR A FUNCTIONAL KEYWORD IN TABLE NAMES**

##### Modify (ALTER) table (in *master* schema)

Modifying a table, always in *master* schema, is done with a standard SQL statement (ALTER TABLE); will launch a trigger to cascade the modifiction. This trigger also launches several checks to ensure child schemas are still in line with *master* and, if necessary, perform correction actions.  
Here is the related checklist:

* Check names: all objects should have names corresponding to the defined structures. If this is not the case, it means that changes have been made locally, on one or several *child* schemas, which should not occur: this is corrected accordingly.
* Check primary keys: ensure all primary keys in the *master* are defined in each *child*. If some differences are found, they are corrected.
* Check foreign keys : same as primary keys
* Check sequences : idem
* Check roles : idem

Most of these controls are performed thanks to scripts which are described later on in this document.

##### Delete table (in *master* schema)

Use the standard SQL statement : `DROP TABLE [table_name] CASCADE`.
This action is **irreversible**  

It launches *ddl_trigger_drop_table_fct* which will delete the table in each *child* schema.

##### Create / Update / Delete indexes

There is one trigger for each action and each one propagates the action within childre schemas as soon as the action occurs in the *master* schema:

* Creation and update are propagated thanks to *build\_if\_has\_to\_idxs.sql* script
* Deletion is propagated thanks to *delete\_indexes\_on\_cascade.sql* script

#### <a name="Scripts">Scripts</a>

##### Constraints and index renaming

These groups of scripts control the names of constraints and indexes and rename them if necessary.  

3 scripts are dedicated to constraints renaming:

* *constraint\_naming\_control\_limiter.sql*: counts the number of constraints to be renamed
* *constraint\_naming\_control\_first.sql*: rename constraints
* *constraint\_naming\_control.sql*: rename constraints => still used ???

2 scripts are dedicated to index renaming;

* *index\_naming\_control\_limiter.sql*: counts the number of indexes to be renamed
* *index\_naming\_control\_first.sql*: rename indexes

Each group works the same way and, for technical reason, led to recursive programs:

1. A first loop references constraints / indexes to be renamed
2. For each constraint / index to rename, build and launch related query

These scripts are autamtically launched when *master* schema objects are created or modified, to clean client schemas on a regular basis. They are launched before any other action is performed.

##### Tables propagation (build\_if\_has\_to\_tables.sql)

This sript is launched by *ddl\_trigger\_create\_table\_fct* event trigger to create, in each child shema, the table that has just been created in *master* schema.

##### Primary keys propagation (build\_if\_has\_to\_pks.sql / drop\_cascade\_pks.sql)

This procedure creates primary keys in each table in children schemas if a primary key exists in the *master* schema that has not been deployed yet (it actually should never occur, but the procedure is defined to make the system more robust).
Primary keys are named according to the following structure : 'pk\_' || m.table\_name || ' \_ ' || c.schema\_name || '

##### Foreign keys propagation (build\_if\_has\_to\_fks.sql / drop\_cascade\_fks.sql)

This procedure creates foreign keys in each table in children schemas if a foreign key exists in the *master* schema that has not been deployed yet.
The procedure build the following SQL command to create necessary foreign keys :
<code>ALTER TABLE ||c.schema\_name||.||m.table\_name|| <br/>
ADD CONSTRAINT fk\_||m.table\_name||\_||m.ref\_table\_name||\_||c.schema\_name|| <br/>
FOREIGN KEY (||m.ref\_columns||) REFERENCES ||c.schema\_name||.||m.ref\_table\_name||(||m.ref\_columns||);</code>

##### Sequences propagation (build\_if\_has\_to\_sqs.sql)

The first step is to delete all sequences named 'seq\_pk\_%' and that are not default values for any column within *master* schema anymore (this action is **irreversible** but is not supposed to have any impact).
Then, for each table within *master* schema, create missing sequences on columns that meet the following conditions:

* Has a primary key and is the only columùn the key is defined on
* The data type is an integer (small int, int or big int)
* It has no sequence as default value yet

Then, for eache table within *master* schema, rename sequences on primary keys when the current name is not: 'sq\_pk\_[nom_table]'
Finally, provides *writer* roles with USAGE privileges on the sequences named 'seq\_pk\_%'.

##### Indexes propagation (build\_if\_has\_to\_idxs.sql / delete\_indexes\_on\_cascade.sql)

This procedure is based on the standard PostgreSQL functions : `pg_get_indexdef()`
It creates all indexes that exist in *master* schema but not in children ones.

##### Roles propagation (build\_if\_has\_to\_roles.sql / drop\_cascade\_roles.sql)

When a column is added or deleted in a table within *master* schema, the change is replicated within all childre schemas. But the privileges are not automatically granted and this procedures will perform this action : UPDATE and INSERT privileges are granted to *writers* for each schema.  
All columns are concerned, except those that are primary keys with a dedicated sequence.

#### <a name="Tools">Tools</a>

##### Initialization (init\_common.sql)

This script is launched to initialize the database and will create the following tables in *common* schema:

* *dwh_dm_client*: list of childre schemas
* *purge_tool_conf*: data purge configuration table (see 'Data purge' for details)
* *vacuum_script_results*: stores results of vacuum and analizes (see 'Vacuum and analyse' for details)

It also creates necessary sequences.

##### Reset foreign keys (reset\_fks.sql)

It happend that some foreign keys have not been correctly initialized and this scripts is buld to reset them if necessary.
All foreign keys will be droped, then the propagation script *build\_if\_has\_to\_fks.sql* is launched.

##### Data purge (data\_purge.sql)

Launch the script with the following command: `CALL common.data_purge();`

This script will purge data according to a predefined configuration.

This configuration is defined in a table : common.purge\_tool\_conf and has the following columns:

* table\_name: checks if table exists or not
* column\_name: checks if column exists or not
* retentionInterval: a string that has to have the structure : "[number]' '[day/month/year]"

The script will first launch scripts to check data in the configuration table:

* *check\_table\_presence.sql*: checks if table exists
* *check\_column\_presence.sql*: checks if column exists in above table
* *check\_data\_purge\_retentionInterval.sql*: checks the format of *retentionInterval*.

Then, it will purge data in the tables and columns listed in the configuration table: for each child schema, it will remove data corresponding to a date earlier than today minus retentionIntervall.

It will raise an error if configuration table is empty.

##### Vacuum and analyze (sys\_vacuum\_diag.sql)

Launch the script with the following command: `SELECT * FROM common.sys_vacuum_diag('[schema_name]')`

For a given schema, this script will provide with a summary of changes that need to be made; the information is displayed with the following structure:

* schema name
* table name
* whether an ANALYZE commande has been launched
* whether a VACUUM commande has been launched
* a comment that can be one of the followings:
  * VACUUM, ANALYZE, CREATE INDEX CONCURRENTLY, CREATE STATISTICS, ALTER TABLE. L''une de ces étapes est en cours.
  * CREATE INDEX en cours
  * CREATE COLLATION, CREATE TRIGGER, ALTER TABLE. L''une de ces étapes est en cours
  * REFRESH MATERIALIZED VIEW CONCURRENTLY en cours
  * DROP TABLE, TRUNCATE, REINDEX, CLUSTER, VACUUM FULL, and REFRESH MATERIALIZED VIEW (without CONCURRENTLY). L''une de ces étapes est en cours.
  * Un VACUUM est déjà en cours sur cette table.
  * Une requête occupe déjà cette table depuis : [query_start]  

The script with launch VACUUM ANALYZE on a table with the following criteria:

* vacuum\_running = false
* dead\_percentage > 25
* nb_sec_from_last_vacuum IS NULL OR nb_sec_from_last_vacuum > 432 000 (5 jours)
* table_size > 100 M

The script with launch ANALYZE on a table with the following criteria:

* vacuum_running = still false
* nb_sec_from_last_analyze > 2 592 000 (30 days)

##### Reindex (sys\_index\_diag)

Prerequisite: execute the command `CREATE EXTENSION pgstattuple;`
Launch the script with the following command: `SELECT * FROM common.sys_index_diag('[schema_name]')`

For a given schema, the script with provide with the following information:

* schema name
* table name
* index name
* a status that can be 'HAS TO BE DELETED?' or 'REINDEXED'

The script will renew *btree* indexes in the given schema where fragmentation is higher than 30%.  
The output is a list of indexes that could be deleted, which means meeting the following criteria:

* has never been used
* is not part of an *expression*
* is not *unique*
* is not used as a constraint

After index renewing, an ANALYZE command is launched to update statistics.

##### Up Master release (dwh\_up\_version\_caller.bash / up\_versioni.sql)

This script will be used to deploy features changes within the application and will be launched by the bash script: `dwh_up_version_caller.bash`

A dump of *master* structure is stored in common.versionning table, which has the following structure:

* a unique incremental ID
* ip address of user applying updates
* date of update
* SQL script used to generate schema (as string)

##### Auto update logger (deblog.sql)

This logging system intends to follow updates on *master* schema.
All changes are managed by the above described scripts and procedures and each one includes a call to this script to log related changes or exceptions if any.  

the information is stored with the following details:

* ip sending the log
* date of execution
* launched query
* name of the procedure or script that launched the query

**LIMITATION:** it is not yet possible to store a transcription of the query that launch an event trigger (it would be necessary to create a C script). Thus, only queries launched within procedures and fonctions laucnhed by event triggers are logged.

In each function, for each query, it stores the executed query. If the procedure fails, the error description is looged instead, including status 0.

To see logs, use the following query: `SELECT * FROM common.deblog ORDER BY 2 DESC;`

##### Check if a string can be converte to an interger (isnumeric.sql)

This control is used in serveral scripts so it has been automated.

## <a name="Recommandations">Recommandations</a>  

Ti use these tools more efficiently, we strongly recommand you follow thses guidelines:

* Each table created in *master* schema should ave a primary key base on a single integer column. This will allow, between others, to use indexes with RANGE function (even if CLUSTERS based on dates are frequently more efficient for oldest data)
* If you need to have a foreign key based on another (other) column(s) than the primary key, you should defin a unique index on this (these) column(s).
* You could envisage to delete *password* column from *common* table. It could make sens, but take care that maintenance will be much more complex. On top of that, only an administrator is supposed to access to this table.

### Unit testing

Automated unit tests are provided in *unit_test* schema and it's important to maintain during new release development.
To launch thses tests, use SQL procedure : *global\_test\_script.sql*

### Limitations

These are some limitations of the different tools, due to technical choices made in the original context; there are some development subjects for future releases.

* A unique constraint (by constraint or by index) cannot be inherited. Thus, if a constraint is defined in a table in *master* schema, it will not be automatically propagated. Of course, there are script to perform this, but the created index will be different for each table and it will not be possible, for instance, to ensure a cross-schema unicity.
* Heritage for CHECK constraints are not taken into account yet
* Partitionning is not active yet and native paritionning is not possible with PostgreSQL 11 because it is not possible to [create a partition for inherited tables](https://www.postgresql.org/docs/current/ddl-partitioning.html)
* An index **MUST NOT** have 'master' in its name (except of course to describe its schema)

### Future evolutions

You might want to have users with cross-schema roles, ate least as reader, but it requires to have dedicated queries to access related data: each query will need to know the different schemas for each table to be requested.
A way to do this is to envisage to create some kinds of groups: create a 'group_schema' that inherits from *master*, then child schemas that inherit from this group. But it will any require some additional development effort.

Purge mechanism could also be improved to have different configurations for each child schema, instead of one signle configuration for every schema.
