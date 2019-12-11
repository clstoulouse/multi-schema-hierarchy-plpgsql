create schema if not exists unit_tests;

create table if not exists unit_tests.test_category
(
	id int primary key
	, category_name varchar (50)
);

create table if not exists unit_tests.test
(
	id int primary key
	, tested_function_name varchar(250)
);

create table if not exists unit_tests.test_part
(
	id int primary key
	, testing_method_name varchar(250) unique
	, category_id int references unit_tests.test_category (id)
	, test_id int references unit_tests.test (id)
);

create table if not exists unit_tests.detail_report_table
(
	id serial primary key
	, execution_timestamp timestamp
	, test_part_id int references unit_tests.test_part (id)	
	, status bit
	, commentary text
);