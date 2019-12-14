# PostgreSQL Notes

## create

```sql
create table auth_user (id serial primary key, username varchar(100) not null);
```



## insert

```sql
insert into auth_user (username) values ('aaron');
```



## select

```sql
select * from auth_user where id = 1;
```

