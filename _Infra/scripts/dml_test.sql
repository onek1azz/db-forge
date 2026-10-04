-- 1. Пользователи (position_id=1 'Капитан', type_of_equipment_id=1 'ДМК')
INSERT INTO users (id, name, position_id, type_of_equipment_id) VALUES (2, 'Петров П.П.', 1, 1);
INSERT INTO users (id, name, position_id, type_of_equipment_id) VALUES (3, 'Сидоров С.С.', 1, 1);
INSERT INTO users (id, name, position_id, type_of_equipment_id) VALUES (4, 'Козлов К.К.', 1, 1);

-- 2. Пачки измерений (имя в формате ДДЧЧМ: день, часы, десятки минут)
INSERT INTO packs (id, name, created_date, user_id) VALUES (2,  '12081', '2026-01-12', 2);
INSERT INTO packs (id, name, created_date, user_id) VALUES (3,  '03104', '2026-02-03', 2);
INSERT INTO packs (id, name, created_date, user_id) VALUES (4,  '21145', '2026-04-21', 2);
INSERT INTO packs (id, name, created_date, user_id) VALUES (5,  '09073', '2026-06-09', 2);
INSERT INTO packs (id, name, created_date, user_id) VALUES (6,  '17122', '2026-03-17', 3);
INSERT INTO packs (id, name, created_date, user_id) VALUES (7,  '05190', '2026-05-05', 3);
INSERT INTO packs (id, name, created_date, user_id) VALUES (8,  '28164', '2026-07-28', 3);
INSERT INTO packs (id, name, created_date, user_id) VALUES (9,  '19111', '2026-08-19', 3);  -- ПРОБЛЕМА: пачка без параметров
INSERT INTO packs (id, name, created_date, user_id) VALUES (10, '14066', '2026-09-14', 4);
INSERT INTO packs (id, name, created_date, user_id) VALUES (11, '02153', '2026-10-02', 4);  -- ПРОБЛЕМА: пропущено направление ветра
INSERT INTO packs (id, name, created_date, user_id) VALUES (12, '24132', '2026-11-24', 4);  -- ПРОБЛЕМА: давление вне диапазона
INSERT INTO packs (id, name, created_date, user_id) VALUES (13, '10100', '2026-12-10', 4);

-- 3. Параметры
-- parameter_type_id: 1 высота (м), 2 температура (°C), 3 давление (мм рт. ст.),
--                    4 направление ветра (деления угломера), 5 скорость ветра (м/с)
-- parameter_type_id=6 (дальность сноса пуль) не используется

-- Пачка 2 — полный набор
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (7,  2, 1, '120');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (8,  2, 2, '-12.5');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (9,  2, 3, '748');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (10, 2, 4, '15');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (11, 2, 5, '4');

-- Пачка 3 — полный набор
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (12, 3, 1, '245');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (13, 3, 2, '3.8');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (14, 3, 3, '752');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (15, 3, 4, '32');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (16, 3, 5, '7');

-- Пачка 4 — полный набор
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (17, 4, 1, '68');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (18, 4, 2, '21.4');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (19, 4, 3, '741');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (20, 4, 4, '50');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (21, 4, 5, '11');

-- Пачка 5 — полный набор
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (22, 5, 1, '310');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (23, 5, 2, '-45.2');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (24, 5, 3, '706');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (25, 5, 4, '08');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (26, 5, 5, '13');

-- Пачка 6 — полный набор
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (27, 6, 1, '150');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (28, 6, 2, '17.6');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (29, 6, 3, '755');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (30, 6, 4, '27');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (31, 6, 5, '6');

-- Пачка 7 — полный набор, ПРОБЛЕМА: температура 75.0 вне диапазона (-58..58)
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (32, 7, 1, '95');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (33, 7, 2, '75.0');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (34, 7, 3, '730');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (35, 7, 4, '44');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (36, 7, 5, '9');

-- Пачка 8 — полный набор
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (37, 8, 1, '410');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (38, 8, 2, '-3.2');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (39, 8, 3, '718');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (40, 8, 4, '12');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (41, 8, 5, '14');

-- Пачка 9 — параметров нет (пустая пачка)

-- Пачка 10 — полный набор
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (42, 10, 1, '27');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (43, 10, 2, '28.9');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (44, 10, 3, '761');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (45, 10, 4, '38');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (46, 10, 5, '5');

-- Пачка 11 — только 4 параметра из 5, ПРОБЛЕМА: отсутствует направление ветра (type 4)
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (47, 11, 1, '180');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (48, 11, 2, '9.5');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (49, 11, 3, '744');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (50, 11, 5, '8');

-- Пачка 12 — полный набор, ПРОБЛЕМА: давление 950 вне диапазона (500..900)
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (51, 12, 1, '52');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (52, 12, 2, '-18.7');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (53, 12, 3, '950');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (54, 12, 4, '21');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (55, 12, 5, '3');

-- Пачка 13 — полный набор
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (56, 13, 1, '376');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (57, 13, 2, '35.1');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (58, 13, 3, '724');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (59, 13, 4, '55');
INSERT INTO parameters (id, pack_id, parameter_type_id, value) VALUES (60, 13, 5, '10');