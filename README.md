# Noveo
First:
  * Install dependencies with `mix deps.get`
  * Create database with `mix ecto.reset`
Second(To start your Phoenix server):
  * Start Phoenix endpoint with `mix phx.server`
  When you start your app all data of jobs and prefessions would be uploaded to cache



## Task 1
  * to shot table run `Noveo.Employment.print_table_of_jobs()`

## Task 2
  Во стором заднии у нас условие, что данные хранятся в базе данных и поступают они туда же.
  Можно организовать Repo.Stream с базы данных, так как данные у нас поступают каждую секунду.
  
  Если бы данные поступали не в базу, а в Agent, Можно сделать GenServer, чтобы фетчить данные с Agent.
  В этом варианте Stream нам поможет, мы может каждую секнду или чуть меньше фетчить данные и отправлять, например, по сокетам 
## Task 3
A Json api recievs onl one get request with 3 params [latitude, longitude, radius]
There are 2 tests in test Modue for Example. 
If ypu want you can make get request from curl of postman