

-- homework 3


--task1
--�������: ��� ������� ������ ���������� ����� �������� ����� ������, ����������� � ���������. �������: ����� � ����� ����������� ��������.

SELECT c.class, COUNT(s.ship)
FROM classes c
  LEFT JOIN
    (
       SELECT o.ship, sh.class
       FROM outcomes o
       LEFT JOIN ships sh ON sh.name = o.ship
       WHERE o.result = 'sunk'
    ) AS s ON s.class = c.class OR s.ship = c.class
GROUP BY c.class

--task2
--�������: ��� ������� ������ ���������� ���, ����� ��� ������ �� ���� ������ ������� ����� ������. ���� ��� ������ �� ���� ��������� ������� ����������, 
--���������� ����������� ��� ������ �� ���� �������� ����� ������. �������: �����, ���.

SELECT c.class, t.y
FROM classes c
LEFT JOIN
(SELECT class, MIN(launched) AS y
FROM ships
GROUP BY class
) AS t ON c.class = t.class

--task3
--�������: ��� �������, ������� ������ � ���� ����������� �������� � �� ����� 3 �������� � ���� ������, ������� ��� ������ � ����� ����������� ��������.

SELECT c.class, SUM(sh.sunked)
FROM classes c
  LEFT JOIN (
     SELECT t.name AS name, t.class AS class,
           CASE WHEN o.result = 'sunk' THEN 1 ELSE 0 END AS sunked
     FROM
     (
      SELECT name, class
      FROM ships
      UNION
      SELECT ship, ship
      FROM outcomes
     )
     AS t
    LEFT JOIN outcomes o ON t.name = o.ship
  ) sh ON sh.class = c.class
GROUP BY c.class
HAVING COUNT(DISTINCT sh.name) >= 3 AND SUM(sh.sunked) > 0

--task4
--�������: ������� �������� ��������, ������� ���������� ����� ������ ����� ���� �������� ������ �� ������������� (������ ������� �� ������� Outcomes).

SELECT name
FROM (SELECT O.ship AS name, numGuns, displacement
FROM Outcomes O INNER JOIN
Classes C ON O.ship = C.class AND
O.ship NOT IN (SELECT name
FROM Ships
)
UNION
SELECT S.name AS name, numGuns, displacement
FROM Ships S INNER JOIN
Classes C ON S.class = C.class
) OS INNER JOIN
(SELECT MAX(numGuns) AS MaxNumGuns, displacement
FROM Outcomes O INNER JOIN
Classes C ON O.ship = C.class AND
O.ship NOT IN (SELECT name
FROM Ships
)
GROUP BY displacement
UNION
SELECT MAX(numGuns) AS MaxNumGuns, displacement
FROM Ships S INNER JOIN
Classes C ON S.class = C.class
GROUP BY displacement
) GD ON OS.numGuns = GD.MaxNumGuns AND
OS.displacement = GD.displacement

--task5
--������������ �����: ������� �������������� ���������, ������� ���������� �� � ���������� ������� RAM � � ����� ������� ����������� ����� ���� ��, ������� ���������� ����� RAM. �������: Maker

SELECT DISTINCT maker
FROM product
WHERE model IN (
SELECT model
FROM pc
WHERE ram = (
  SELECT MIN(ram)
  FROM pc
  )
AND speed = (
  SELECT MAX(speed)
  FROM pc
  WHERE ram = (
   SELECT MIN(ram)
   FROM pc
   )
  )
)
AND
maker IN (
SELECT maker
FROM product
WHERE type='printer'
)

-- homework 4

--task13 (lesson3)
--������������ �����: ������� ������ ���� ��������� � ������������� � ��������� ���� �������� (pc, printer, laptop). �������: model, maker, type

select *
from product;

--task14 (lesson3)
--������������ �����: ��� ������ ���� �������� �� ������� printer ������������� ������� ��� ���, � ���� ���� ����� ������� PC - "1", � ��������� - "0"

select *,
case 
	when price > (select avg(price) from pc) then 1
	else 0
end flag
from printer;


--task15 (lesson3)
--�������: ������� ������ ��������, � ������� class ����������� (IS NULL)

select *
from ships 
join classes
on classes.class = ships.class
where classes.class is null;

--task16 (lesson3)
--�������: ������� ��������, ������� ��������� � ����, �� ����������� �� � ����� �� ����� ������ �������� �� ����.

with battle_1 as 
	(
	select name, extract(year from date) as year
	from battles
	)
select * 
from battle_1
where year not in (select launched from ships)

--task17 (lesson3)
--�������: ������� ��������, � ������� ����������� ������� ������ Kongo �� ������� Ships.

select battle
from outcomes
where ship in (select name from ships where class = 'Kongo')

--task1  (lesson4)
-- ������������ �����: ������� view (�������� all_products_flag_300) ��� ���� ������� (pc, printer, laptop) � ������, ���� ��������� ������ > 300. �� view ��� �������: model, price, flag

create view all_products_flag_300 as
select model, price, flag
from (
	select *,
	case
	when price > 300 then 1
	else 0
	end flag
	from (
		select product.model, price
		from product 
		join pc 
		on pc.model = product.model
	union all
		select product.model, price
		from product 
		join laptop 
		on laptop.model = product.model
	union all
		select product.model, price
		from product 
		join printer 
		on printer.model = product.model
	) a
) b
group by flag, model, price;

select *
from all_products_flag_300;

--task2  (lesson4)
-- ������������ �����: ������� view (�������� all_products_flag_avg_price) ��� ���� ������� (pc, printer, laptop) � ������, ���� ��������� ������ c������ . �� view ��� �������: model, price, flag

create view all_products_flag_avg_price as
with all_products_flag_avg_price_1 as
(
		select product.model, price
		from product 
		join pc 
		on pc.model = product.model
	union all
		select product.model, price
		from product 
		join laptop 
		on laptop.model = product.model
	union all
		select product.model, price
		from product 
		join printer 
		on printer.model = product.model
	)
select model, price,
case when price > (select avg(price) from all_products_flag_avg_price_1) then 1
	else 0	
end flag
from all_products_flag_avg_price_1
group by flag, model, price;


select *
from all_products_flag_avg_price;

--task3  (lesson4)
-- ������������ �����: ������� ��� �������� ������������� = 'A' �� ���������� ���� ������� �� ��������� ������������� = 'D' � 'C'. ������� model

select printer.model
from printer
join product 
on product.model = printer.model
where maker = 'A' 
and price > 
(
	select avg(price) 
	from printer 
	join product 
	on product.model = printer.model
	where maker = 'D' 
)
and price > (
	select avg(price) 
	from printer 
	join product 
	on product.model = printer.model
	where maker = 'C')

--task4 (lesson4)
-- ������������ �����: ������� ��� ������ ������������� = 'A' �� ���������� ���� ������� �� ��������� ������������� = 'D' � 'C'. ������� model

	with model_1 as
(
		select product.model, price, maker
		from product 
		join pc 
		on pc.model = product.model
	union all
		select product.model, price, maker
		from product 
		join laptop 
		on laptop.model = product.model
	union all
		select product.model, price, maker
		from product 
		join printer 
		on printer.model = product.model
)
select model
from model_1 
where price >
(
	select avg(price) 
	from printer 
	join product 
	on product.model = printer.model
	where maker = 'D'
)
and maker = 'A'
and price > (
	select avg(price) 
	from printer 
	join product 
	on product.model = printer.model
	where maker = 'C')
--task5 (lesson4)
-- ������������ �����: ����� ������� ���� ����� ���������� ��������� ������������� = 'A' (printer & laptop & pc)
	
	with model_123 as
		(
		select product.model, price, maker
		from product 
		join pc 
		on pc.model = product.model
	union all
		select product.model, price, maker
		from product 
		join laptop 
		on laptop.model = product.model
	union all
		select product.model, price, maker
		from product 
		join printer 
		on printer.model = product.model
		)
select model, avg(price)
from model_123
where model in 
		(
		select distinct(model)
		from product 
		where maker = 'A' 
		)
group by model;

--task6 (lesson4)
-- ������������ �����: ������� view � ����������� ������� (�������� count_products_by_makers) �� ������� �������������. �� view: maker, count

create view count_products_by_makers as
select maker, count(*) 
from product
group by maker
order by maker;

select *
from count_products_by_makers;
--task7 (lesson4)
-- �� ����������� view (count_products_by_makers) ������� ������ � colab (X: maker, y: count)

--task8 (lesson4)
-- ������������ �����: ������� ����� ������� printer (�������� printer_updated) � ������� �� ��� ��� �������� ������������� 'D'

create table printer_updated as table printer;

DELETE from printer_updated
WHERE model in 
(
select model
from product
where maker = 'D'
);

select *
from printer_updated;

--task9 (lesson4)
-- ������������ �����: ������� �� ���� ������� (printer_updated) view � �������������� �������� ������������� (�������� printer_updated_with_makers)

create view printer_updated_with_makers as
select code, printer_updated.model, color, printer_updated.type, price, maker
from printer_updated
join product 
on product.model = printer_updated.model;

select *
from printer_updated_with_makers;

--task10 (lesson4)
-- �������: ������� view c ����������� ����������� �������� � ������� ������� (�������� sunk_ships_by_classes). �� view: count, class (���� �������� ������ ���/IS NULL, �� �������� �� 0)

create view sunk_ships_by_classes as
with all_ships as (
	select name, class
	from ships
	union all
	select distinct ship, NULL as class
	from Outcomes
	where ship not in (select name from ships) 
)
select class, count(*) from all_ships where name in 
	(
	select ship
	from outcomes
	where result = 'sunk'
	) group by class;

select *
from sunk_ships_by_classes;
--task11 (lesson4)
-- �������: �� ����������� view (sunk_ships_by_classes) ������� ������ � colab (X: class, Y: count)

--task12 (lesson4)
-- �������: ������� ����� ������� classes (�������� classes_with_flag) � �������� � ��� flag: ���� ���������� ������ ������ ��� ����� 9 - �� 1, ����� 0

create table classes_with_flag as 
select *,
case 
	when numguns >= 1 then 1
	else 0
end flag
from classes;

select *
from classes_with_flag;

--task13 (lesson4)
-- �������: ������� ������ � colab �� ������� classes � ����������� ������� �� ������� (X: country, Y: count)

--task14 (lesson4)
-- �������: ������� ���������� ��������, � ������� �������� ���������� � ����� "O" ��� "M".

with names as
	( 
	select name
	from ships 
	where name like 'O%' or name like 'M%'
	)
select count(*) from names;

--task15 (lesson4)
-- �������: ������� ���������� ��������, � ������� �������� ������� �� ���� ����.

with names_1 as
	( 
	select *
	from ships
	where name like '% %'
	)
select count(*) from names_1;

--task16 (lesson4)
-- �������: ��������� ������ � ����������� ���������� �� ���� �������� � ����� ������� (X: year, Y: count)
