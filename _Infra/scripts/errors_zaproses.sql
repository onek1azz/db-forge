-- список параметров с ошибками
with pack_parameters as (
	select
		p.id as pack_id,
		p.eq_type_id,
		max(case when pt.code = 'height' then x.value end) as height,
		max(case when pt.code = 'temperature' then x.value end) as temperature,
		max(case when pt.code = 'pressure' then x.value end) as pressure,
		max(case when pt.code = 'wind_direction' then x.value end) as wind_direction,
		max(case when pt.code = 'wind_speed' then x.value end) as wind_speed,
		max(case when pt.code = 'drift_range' then x.value end) as drift_range
	from packs p
	left join parametrs x on x.pack_id = p.id
	left join parameter_types pt on pt.id = x.parameter_type_id
	group by p.id, p.eq_type_id
),
pack_errors as (
	select
		pp.*,
		check_parameters(cast(row(
			pp.eq_type_id, pp.height, pp.temperature, pp.pressure,
			pp.wind_direction, pp.wind_speed, pp.drift_range
		) as parameter_list)) as error_text
	from pack_parameters pp
)
select
	pe.pack_id as "№",
	et.name as "Тип оборудования",
	pe.height as "Высота метеопоста",
	pe.temperature as "Температура",
	pe.pressure as "Давление",
	pe.wind_direction as "Направление ветра",
	pe.wind_speed as "Скорость ветра",
	pe.drift_range as "Дальность сноса пуль",
	pe.error_text <> '' as "Флаг: Есть ошибка",
	nullif(pe.error_text, '') as "Описание ошибки"
from pack_errors pe
inner join eq_types et on et.id = pe.eq_type_id
order by pe.pack_id;


-- лучший стрелок
with pack_parameters as (
	select
		p.id as pack_id,
		p.eq_type_id,
		max(case when pt.code = 'height' then x.value end) as height,
		max(case when pt.code = 'temperature' then x.value end) as temperature,
		max(case when pt.code = 'pressure' then x.value end) as pressure,
		max(case when pt.code = 'wind_direction' then x.value end) as wind_direction,
		max(case when pt.code = 'wind_speed' then x.value end) as wind_speed,
		max(case when pt.code = 'drift_range' then x.value end) as drift_range
	from packs p
	left join parametrs x on x.pack_id = p.id
	left join parameter_types pt on pt.id = x.parameter_type_id
	group by p.id, p.eq_type_id
),
pack_errors as (
	select
		pp.pack_id,
		check_parameters(cast(row(
			pp.eq_type_id, pp.height, pp.temperature, pp.pressure,
			pp.wind_direction, pp.wind_speed, pp.drift_range
		) as parameter_list)) as error_text
	from pack_parameters pp
),
pack_error_counts as (
	select
		pe.pack_id,
		case
			when pe.error_text = '' then 0
			else cardinality(string_to_array(pe.error_text, '; '))
		end as error_count
	from pack_errors pe
),
user_errors as (
	select
		u.id,
		u.full_name,
		cast(coalesce(sum(pc.error_count), 0) as integer) as error_count
	from users u
	left join packs p on p.user_id = u.id
	left join pack_error_counts pc on pc.pack_id = p.id
	group by u.id, u.full_name
)
select
	rank() over (order by ue.error_count) as "Место",
	ue.full_name as "Пользователь",
	ue.error_count as "Количество ошибок"
from user_errors ue
order by "Место", ue.full_name;