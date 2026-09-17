drop table if exists users cascade;
drop table if exists packs cascade;
drop table if exists positions cascade;
drop table if exists type_of_equipment cascade;
drop table if exists parameters cascade;


create table packs (
	id int primary key,
	name text
);

create table users (
	id int primary key,
	name text
);

create table positions (
	id int primary key,
	name text
);

create table type_of_equipment (
	id int primary key,
	name text
);

create table parameters (
	id int primary key,
	name text
);

alter table users add column pack_id int;
alter table users add column position_id int;
alter table users add column type_of_equipment_id int;
alter table users add column parameter_id int;


insert into packs values (1, 'пачка1');
insert into positions values (1, 'капитан');
insert into type_of_equipment values (1, 'ноутбук');
insert into parameters values (1, 'параметр1');

insert into users values (1, 'Иванов', 1, 1, 1, 1);

select 
u.name as user_name,
p.name as pack_name,
pos.name as position_name,
eq.name as equipment_name,
param.name as parameter_name 
from users u join packs p on u.pack_id = p.id
join positions pos on u.position_id = pos.id
join type_of_equipment eq on u.type_of_equipment_id = eq.id
join parameters param on u.parameter_id = param.id;
