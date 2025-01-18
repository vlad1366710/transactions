create table animals_zoo(
    id bigserial primary key ,
    вид text not null,
    количество integer not null check ( количество > 0 )

);
insert into  animals_zoo(вид, количество) values ('слон', 5);
insert into  animals_zoo(вид, количество) values ('лиса', 3);
insert into  animals_zoo(вид, количество) values ('заяц', 4);
select * from animals_zoo

--атомарность
begin;
insert into  animals_zoo(вид, количество) values ('олень', 5);
update  animals_zoo set  количество = 10 where вид = 'лиса';
delete from animals_zoo where  вид = 'заяй';
select * from animals_zoo;
rollback ;
select *from animals_zoo;

--согласованность

begin;
select *from animals_zoo;
update  animals_zoo set  количество = -10 where вид = 'лиса';
select *from animals_zoo;
rollback ;
select *from animals_zoo;

--Грязные чтения
begin;
DO $$
declare
    kol integer;
    begin
    select количество from animals_zoo where вид = 'заяц' into  kol;
    update animals_zoo set количество = количество + 5 where вид = 'заяц';
    select количество from animals_zoo where вид = 'заяц' into kol ;
    raise notice '%',kol;
    perform pg_sleep(15);
end;
$$;
rollback;
select *from animals_zoo;
--2
begin;
DO $$
declare
    kol integer;
begin
    select количество from animals_zoo where вид = 'заяц' into  kol;
    raise notice '%',kol;
end;
$$;
commit;




--Неповторяющиеся чтения
begin;
DO $$
declare
    kol integer;
    begin
    select количество from animals_zoo where вид = 'заяц' into  kol;
    perform pg_sleep(15);
    select количество from animals_zoo where вид = 'заяц' into kol ;
    raise notice '%',kol;
end;
$$;
commit ;
select *from animals_zoo;
--2
begin;
DO $$
declare
begin
        update animals_zoo set количество = количество + 5 where вид = 'заяц';
end;
$$;
commit;

--Фантом читает
begin;
DO $$
declare
    kol integer;
    begin
    select count(вид) from animals_zoo where количество > 2  into  kol;
    perform pg_sleep(15);
        select count(вид) from animals_zoo where количество > 2  into  kol;
    raise notice '%',kol;
end;
$$;
commit ;
select *from animals_zoo;
--2
begin;
DO $$
declare
begin
        insert into animals_zoo values ('корова',3);
end;
$$;
commit;

delete from animals_zoo;
begin;
insert into animals_zoo(вид, количество) VALUES ('орел',15);
commit;
--здесь перезапускаем сервер
select * from animals_zoo;








drop  table animals_zoo