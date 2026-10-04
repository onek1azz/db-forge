-- у каждого юзера одинаковое колво измерений?
-- считаем колво пачек у каждого юзера
select
	u.name as "Пользователь",
	count(pr.id) as "Количество измерений"
from users u
left join packs p on p.user_id = u.id
left join parameters pr on pr.pack_id = p.id
group by u.id, u.name
order by u.id;

-- есть ли пачки без единого параметра?
select
	p.id as "Код пачки",
	p.name as "Номер пачки",
	p.created_date as "Дата измерения"
from packs p
left join parameters pr on pr.pack_id = p.id
where pr.id is null;

-- содержит ли каждая пачка полное колво параметров (5 штукк)?
select
	p.id as "Код пачки",
	p.name as "Номер пачки",
	coalesce(count(pr.id), 0) as "Количество параметров",
	case when coalesce(count(pr.id), 0) = 5 then 'Да' else 'Нет' end as "Полный набор"
from packs p
left join parameters pr on pr.pack_id = p.id
group by p.id, p.name
order by p.id;

-- все ли значения параметров в пределах допустимых диапазонов?
-- выводим строки где значение выходит за допустимый
select
	pr.id as "Код значения",
	p.name as "Номер пачки",
	pt.name as "Параметр",
	pr.value as "Значение",
	case
		when pt.id = 2 and (cast(pr.value as numeric) < -58 or cast(pr.value as numeric) > 58) then 'Вне диапазона [-58; 58]'
		when pt.id = 3 and (cast(pr.value as numeric) < 500 or cast(pr.value as numeric) > 900) then 'Вне диапазона [500; 900]'
		when pt.id = 4 and (cast(pr.value as numeric) < 0 or cast(pr.value as numeric) > 59) then 'Вне диапазона [0; 59]'
		when pt.id = 5 and (cast(pr.value as numeric) < 0 or cast(pr.value as numeric) > 15) then 'Вне диапазона [0; 15]'
		else 'В пределах нормы'
	end as "Статус"
from parameters pr
join packs p on p.id = pr.pack_id
join parameter_types pt on pt.id = pr.parameter_type_id
where
	(pt.id = 2 and (cast(pr.value as numeric) < -58 or cast(pr.value as numeric) > 58))
	or (pt.id = 3 and (cast(pr.value as numeric) < 500 or cast(pr.value as numeric) > 900))
	or (pt.id = 4 and (cast(pr.value as numeric) < 0 or cast(pr.value as numeric) > 59))
	or (pt.id = 5 and (cast(pr.value as numeric) < 0 or cast(pr.value as numeric) > 15));

-- все ли единицы измерения верны по отношению к параметрам?
-- выводим только несоответствия, если такие есть
select
	pt.id as "Код параметра",
	pt.name as "Параметр",
	un.name as "Текущая единица измерения",
	case pt.name
		when 'Высота метеопоста' then 'Метр'
		when 'Температура воздуха' then 'Градус Цельсия'
		when 'Давление атмосферы' then 'Миллиметр ртутного столба'
		when 'Направление ветра' then 'Деление угломера'
		when 'Скорость ветра' then 'Метр в секунду'
		when 'Дальность сноса пуль' then 'Метр'
		else 'Неизвестный параметр'
	end as "Ожидаемая единица измерения"
from parameter_types pt
join units un on un.id = pt.unit_id
where un.name <> case pt.name
		when 'Высота метеопоста' then 'Метр'
		when 'Температура воздуха' then 'Градус Цельсия'
		when 'Давление атмосферы' then 'Миллиметр ртутного столба'
		when 'Направление ветра' then 'Деление угломера'
		when 'Скорость ветра' then 'Метр в секунду'
		when 'Дальность сноса пуль' then 'Метр'
		else 'Неизвестный параметр'
	end;