create table devices(
                        id serial primary key ,
                        product_name varchar not null,
                        product_company varchar not null ,
                        price numeric not null
);

create table customers (
                           id serial primary key ,
                           name varchar not null
);

create table cheques(
                        id serial primary key ,
                        device_id int references devices(id),
                        customer_id int references customers(id),
                        price numeric not null,
                        date_of_purchase  date  not null
);
INSERT INTO devices (product_name, product_company, price)
VALUES  ('iPhone 13', 'Apple', 1200),
        ('MacBook Air', 'Apple', 1800),
        ('Galaxy S22', 'Samsung', 1100),
        ('ThinkPad X1', 'Lenovo', 1500),
        ('iPad Pro', 'Apple', 1300),
        ('Galaxy Tab', 'Samsung', 900);

INSERT INTO customers (name)
VALUES ('Adina'),
       ('Aidana'),
       ('Nursultan'),
       ('Samagan'),
       ('Muxammad');

INSERT INTO cheques (device_id, customer_id, price, date_of_purchase)
VALUES (1, 1, 1200, '2024-01-10'),
       (2, 1, 1800, '2024-01-15'),
       (3, 2, 1100, '2024-02-01'),
       (1, 3, 1200, '2024-02-10'),
       (4, 4, 1500, '2024-02-20'),
       (5, 5, 1300, '2024-03-01'),
       (1, 2, 1200, '2024-03-05'),
       (6, 3, 900,  '2024-03-10');

SELECT * FROM devices;
SELECT * FROM customers;
SELECT * FROM cheques;
--1. Получить имена клиентов, которые покупали устройства дороже средней цены всех устройств
SELECT DISTINCT c.name
FROM cheques ch
         JOIN customers c ON ch.customer_id = c.id
         JOIN devices d ON ch.device_id = d.id WHERE d.price > (SELECT AVG(price) FROM devices);

--2.Получить список компаний, чьи устройства никогда не покупались
SELECT DISTINCT d.product_company
FROM devices d
         LEFT JOIN cheques ch ON d.id = ch.device_id
WHERE ch.device_id IS NULL;
-- 3. Найти устройства, которые покупались больше одного раза
SELECT d.product_name
FROM devices d
         JOIN cheques ch ON d.id = ch.device_id
GROUP BY d.product_name
HAVING COUNT(*) > 1;
--4. Вывести клиентов, купивших самое дорогое устройство
SELECT DISTINCT c.name
FROM customers c
         JOIN cheques ch ON c.id = ch.customer_id
         JOIN devices d ON ch.device_id = d.id
WHERE d.price = (SELECT MAX(price) FROM devices);
--5. Найти клиентов, которые купили хотя бы одно устройство от компании "Apple"
SELECT DISTINCT c.name
FROM customers c
         JOIN cheques ch ON c.id = ch.customer_id
         JOIN devices d ON ch.device_id = d.id
WHERE d.product_company = 'Apple';
--6. Вывести клиентов, которые не купили ни одного устройства, стоящего меньше 500
SELECT c.name
FROM customers c
WHERE c.id NOT IN (
    SELECT ch.customer_id
    FROM cheques ch
             JOIN devices d ON ch.device_id = d.id
    WHERE d.price < 500
);
--7. Вывести клиентов, чья общая сумма покупок больше, чем средняя сумма всех клиентов
SELECT c.name
FROM customers c
         JOIN cheques ch ON c.id = ch.customer_id
GROUP BY c.name
HAVING SUM(ch.price) > (
    SELECT AVG(total_sum)
    FROM (
             SELECT SUM(price) AS total_sum
             FROM cheques
             GROUP BY customer_id ) t
);
--8. Получить название самого часто покупаемого устройства
SELECT d.product_name
FROM devices d
         JOIN cheques ch ON d.id = ch.device_id
GROUP BY d.product_name
ORDER BY COUNT(*) DESC
    LIMIT 1;
--9. Устройства с ценой выше средней цены для каждого типа
SELECT d.product_name, d.product_company, d.price
FROM devices d
WHERE d.price > (
    SELECT AVG(price)
    FROM devices
    WHERE product_company = d.product_company
);

--10. Клиенты, купившие устройства типа LAPTOP
SELECT DISTINCT c.name
FROM customers c
         JOIN cheques ch ON c.id = ch.customer_id
         JOIN devices d ON ch.device_id = d.id
WHERE d.product_name ILIKE '%book%'
   OR d.product_name ILIKE '%ThinkPad%';
--11. Использование CASE: Комментарий по категории устройства
SELECT product_name,price,
       CASE
           WHEN price < 1000 THEN 'Дешевое'
           WHEN price BETWEEN 1000 AND 1500 THEN 'Среднее'
           ELSE 'Дорогое'
           END AS category
FROM devices;
--12. Найти клиентов, которые покупали устройства только одной компании
SELECT c.name
FROM customers c
         JOIN cheques ch ON c.id = ch.customer_id
         JOIN devices d ON ch.device_id = d.id
GROUP BY c.name
HAVING COUNT(DISTINCT d.product_company) = 1;
--13. Найти имя устройства, которое покупали все клиенты
SELECT d.product_name
FROM devices d
         JOIN cheques ch ON d.id = ch.device_id
GROUP BY d.product_name
HAVING COUNT(DISTINCT ch.customer_id) = (
    SELECT COUNT(*) FROM customers
);





