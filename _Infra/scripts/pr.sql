create table solders(
name text,
rank text
);

create table ranks (
	id int,
	name text
)


alter table solders add uniq_id int;

select solders.name || ' - ' || ranks.name as full_name from solders, ranks
where
	solders.rank_id = ranks.id

rank_id is not null

update solders set uniq_id = 2 where rank = 'младший Лейтенант';
update solders set uniq_id = 3 where rank = 'ст / Лейтенант';
update solders set uniq_id = 1 where rank = 'Лейтенант';
update solders set uniq_id = 4 where rank = 'мл / лейтенант';


insert into ranks(id, name) values (1, 'Младший лейтенант');


insert into solders (name, rank) values('Иванов', 'Лейтенант');
insert into solders (name, rank) values('Иванов', 'мл / Лейтенант');
insert into solders (name, rank) values('Иванов', 'ст / Лейтенант');

insert into solders (name, rank) values('Иванов', 'младший Лейтенант');