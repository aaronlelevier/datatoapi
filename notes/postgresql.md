# PostgreSQL Notes

## create

```sql
create table "user" (id serial primary key, username varchar(100) not null);
```



## insert

```sql
insert into "user" (username) values ('aaron');
```



## select

```sql
select * from "user" where id = 1;
```

