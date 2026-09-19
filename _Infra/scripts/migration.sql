drop table if exists pack_parameters cascade;
drop table if exists packs cascade;
drop table if exists users cascade;
drop table if exists positions cascade;
drop table if exists type_of_equipment cascade;
drop table if exists parameters cascade;


create table packs (
	id int primary key,
	name text,
	created_date date
);
comment on table packs is 'Таблица пачек';
comment on column packs.id is 'Уникальный код пачки';
comment on column packs.name is 'Наименование пачки';
comment on column packs.created_date is 'Дата измерения';


create table users (
	id int primary key,
	name text
);
comment on table users is 'Таблица пользователей';
comment on column users.id is 'Уникальный код пользователя';
comment on column users.name is 'Имя пользователя';


create table positions (
	id int primary key,
	name text
);
comment on table positions is 'Таблица должностей';
comment on column positions.id is 'Уникальный код должности';
comment on column positions.name is 'Наименование должности';


create table type_of_equipment (
	id int primary key,
	name text
);
comment on table type_of_equipment is 'Таблица типов оборудования';
comment on column type_of_equipment.id is 'Уникальный код типа оборудования';
comment on column type_of_equipment.name is 'Наименование типа оборудования';


create table parameters (
	id int primary key,
	name text
);
comment on table parameters is 'Таблица параметров';
comment on column parameters.id is 'Уникальный код параметра';
comment on column parameters.name is 'Наименование параметра';

create table pack_parameters (
	id int primary key,
	pack_id int references packs(id),
	parameter_id int references parameters(id),
	value text
);
comment on table pack_parameters is 'Значения параметров для пачек';
comment on column pack_parameters.id is 'Уникальный код связи';
comment on column pack_parameters.pack_id is 'Уникальный код пачки';
comment on column pack_parameters.parameter_id is 'Уникальный код параметра';
comment on column pack_parameters.value is 'Значение параметра';

alter table users add column pack_id int;
alter table users add column position_id int;
alter table users add column type_of_equipment_id int;

insert into packs (id, name, created_date) values (1, '24093', '2026-09-18');
insert into positions (id, name) values (1, 'Капитан');
insert into type_of_equipment (id, name) values (1, 'ДМК');
insert into parameters (id, name) values 
(1, 'Высота метеопоста'),
(2, 'Температура воздуха'),
(3, 'Давление атмосферы'),
(4, 'Направление ветра'),
(5, 'Скорость ветра'),
(6, 'Дальность сноса пуль');

insert into users (id, name) values (1, 'Иванов');
insert into pack_parameters (id, pack_id, parameter_id, value) values 
(1, 1, 1, '100'),
(2, 1, 2, '15'),
(3, 1, 3, '750'),
(4, 1, 4, '00'),
(5, 1, 5, '5'),
(6, 1, 6, '120');

update users set pack_id = 1 where id = 1;
update users set position_id = 1 where id = 1;
update users set type_of_equipment_id = 1 where id = 1;

select 
    u.name as user_name,
    p.name as pack_name,
    p.created_date as pack_date,
    pos.name as position_name,
    eq.name as equipment_name,
    param.name as parameter_name,
    pp.value as parameter_value
from users u 
join packs p on u.pack_id = p.id
join positions pos on u.position_id = pos.id
join type_of_equipment eq on u.type_of_equipment_id = eq.id
join pack_parameters pp on p.id = pp.pack_id
join parameters param on pp.parameter_id = param.id;