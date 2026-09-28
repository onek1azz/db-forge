create table base_units (
	id int primary key,
	name text
);

comment on table base_units is 'Таблица базовых единиц измерения';
comment on column base_units.id is 'Уникальный код базовой единицы измерения';
comment on column base_units.name is 'Наименование физической величины';

create table units (
	id int primary key,
	name text,
	base_unit_id int references base_units(id)
);

comment on table units is 'Таблица единиц измерения';
comment on column units.id is 'Уникальный код единицы измерения';
comment on column units.name is 'Наименование единицы измерения';
comment on column units.base_unit_id is 'Ссылка на базовую единицу измерения';


alter table if exists pack_parameters drop constraint if exists pack_parameters_parameter_id_fkey;

create table parameter_types (
	id int primary key,
	name text,
	unit_id int references units(id)
);

comment on table parameter_types is 'Таблица типов параметров';
comment on column parameter_types.id is 'Уникальный код типа параметра';
comment on column parameter_types.name is 'Наименование типа параметра';
comment on column parameter_types.unit_id is 'Ссылка на единицу измерения';

insert into parameter_types (id, name)
select id, name from parameters;

drop table parameters;

create table parameters (
	id int primary key,
	pack_id int references packs(id),
	parameter_type_id int references parameter_types(id),
	value text
);

comment on table parameters is 'Значения параметров для пачек';
comment on column parameters.id is 'Уникальный код значения параметра';
comment on column parameters.pack_id is 'Ссылка на пачку';
comment on column parameters.parameter_type_id is 'Ссылка на тип параметра';
comment on column parameters.value is 'Значение параметра';

insert into parameters (id, pack_id, parameter_type_id, value)
select id, pack_id, parameter_id, value from pack_parameters;

drop table pack_parameters;

insert into base_units (id, name) values
(1, 'Длина'),
(2, 'Температура'),
(3, 'Давление'),
(4, 'Угол'),
(5, 'Скорость');

insert into units (id, name, base_unit_id) values
(1, 'Метр', 1),
(2, 'Градус Цельсия', 2),
(3, 'Миллиметр ртутного столба', 3),
(4, 'Деление угломера', 4),
(5, 'Метр в секунду', 5);

update parameter_types set unit_id = 1 where id = 1; -- высота метеопоста - метр
update parameter_types set unit_id = 2 where id = 2; -- температура воздуха - градус цельсия
update parameter_types set unit_id = 3 where id = 3; -- давление атмосферы - мм рт ст
update parameter_types set unit_id = 4 where id = 4; -- направление ветра - деление угломера
update parameter_types set unit_id = 5 where id = 5; -- скорость ветра - метр в секунду
update parameter_types set unit_id = 1 where id = 6; -- дальность сноса пуль - метр


select
	p.created_date as "Дата измерения",
	p.name as "Номер пачки",
	u.name as "ФИО сотрудника",
	pt.name || ' (' || un.name || ')' as "Наименование параметра и ед. измерения",
	pr.value as "Значение"
from parameters pr
join packs p on pr.pack_id = p.id
join users u on p.user_id = u.id
join parameter_types pt on pr.parameter_type_id = pt.id
join units un on pt.unit_id = un.id
order by p.created_date, p.name, pt.id;