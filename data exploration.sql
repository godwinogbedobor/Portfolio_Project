--Select Data to be used;

Select location, date, population, total_cases, new_cases, total_deaths 
From Exploration_Portfolio_Project..covid_deaths
Order by location, date


--Total cases vs Total deaths to show likelihood of dying in a country if contracted (Nigeria as a case study)

Select location, date, total_cases, total_deaths,
	ROUND((cast(total_deaths as float)/total_cases) * 100,2) AS Death_Percentage
From Exploration_Portfolio_Project..covid_deaths
Where NOT  total_deaths = 'NULL'
	AND location = 'Nigeria'
	AND continent is not null
Order by date



--Total cases vs population to show what percentage of the United States' population contracted covid, rounded to 2 decimal places.

Select location, date, population, total_cases,	
	ROUND((total_cases/population) * 100,2) AS Infected_Percentage
From Exploration_Portfolio_Project..covid_deaths
Where location like '%states' AND NOT total_cases = 'NULL' AND continent is not null
Order by 2


--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as Highest_infection_count,
	Round(MAX((total_cases/population)) * 100,2) AS Infected_Population_Percentage
From Exploration_Portfolio_Project..covid_deaths
Where  NOT total_cases = 'NULL' AND continent is not null
Group by location, population
Order by Infected_Population_Percentage DESC


--Looking at countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as Total_death_count
From Exploration_Portfolio_Project..covid_deaths
Where continent is not null
Group by location
Order by Total_death_count DESC



--Breaking things down by continents (continents with the highest death count)
Select location, SUM(cast(new_deaths as float)) as Total_death_count
From Exploration_Portfolio_Project..covid_deaths
Where continent is null
Group by location
Order by Total_death_count desc

Select continent, SUM(cast(new_deaths as int)) as total_death_count
From Exploration_Portfolio_Project..covid_deaths
Where continent is not null
Group by continent
Order by Total_death_count desc




--Global numbers
Select Sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
	round((nullif(sum(new_deaths),0)/nullif(Sum(new_cases),0)) * 100,2) as global_death_percentage
from Exploration_Portfolio_Project..covid_deaths
where continent is not null



--Total cases vs Total deaths to show likelihood of dying in a continent if contracted

Select continent, SUM(cast(new_cases as int)) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths,
	Round(SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)) * 100, 3) as DeathPercentage
from Exploration_Portfolio_Project..covid_deaths
where continent is not null  AND total_deaths is not null
Group by continent
Order by continent




--Looking at continents with the highest infection rate

select continent,SUM(population) total_population, SUM(cast(new_cases as float)) as total_infection_count,
	ROUND( (SUM(cast(new_cases as float))/SUM(population)) * 100, 3) as infectionrate
from Exploration_Portfolio_Project..covid_deaths
where continent is not  null
group by continent
order by infectionrate desc






--Looking at total population vs vaccinations
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
from Exploration_Portfolio_Project..covid_deaths as death
join Exploration_Portfolio_Project..covid_vaccinations as vacc
	on death.location = vacc.location
	and death.date = vacc.date

where death.continent is not null
order by 2,3


--Trying a rolling count system for the new vaccinations


select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations as float)) OVER (partition by death.location Order by death.location, death.date) as rolling_count --Count to start over anytime it gets to a new location)
from Exploration_Portfolio_Project..covid_deaths as death
join Exploration_Portfolio_Project..covid_vaccinations as vacc
	on death.location = vacc.location
	and death.date = vacc.date

where death.continent is not null
order by 2,3



--Using a CTE
With population_vs_vaccination(continent, location, date, population, new_vaccinations, rolling_count)
as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations as float)) OVER (partition by death.location Order by death.location, death.date) as rolling_count --Count to start over anytime it gets to a new location)
from Exploration_Portfolio_Project..covid_deaths as death
join Exploration_Portfolio_Project..covid_vaccinations as vacc
	on death.location = vacc.location
	and death.date = vacc.date

where death.continent is not null
--order by 2,3
)

Select *,
	(rolling_count/population) *100
From population_vs_vaccination



--Using a TEMP table
Create Table #vaccination_rates
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_count numeric
)

Insert Into #vaccination_rates
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations as float)) OVER (partition by death.location Order by death.location, death.date) as rolling_count --Count to start over anytime it gets to a new location)
from Exploration_Portfolio_Project..covid_deaths as death
join Exploration_Portfolio_Project..covid_vaccinations as vacc
	on death.location = vacc.location
	and death.date = vacc.date

where death.continent is not null

Select *,
	(rolling_count/population) *100
From #vaccination_rates





--Using the Drop Table if exists clause to make changes in the TEMP Table

Drop Table if exists ##vaccination_ratez
Create Table #vaccination_ratez
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_count numeric
)

Insert Into #vaccination_ratez
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations as float)) OVER (partition by death.location Order by death.location, death.date) as rolling_count --Count to start over anytime it gets to a new location)
from Exploration_Portfolio_Project..covid_deaths as death
join Exploration_Portfolio_Project..covid_vaccinations as vacc
	on death.location = vacc.location
	and death.date = vacc.date

--where death.continent is not null

Select *,
	(rolling_count/population) *100
From #vaccination_ratez







--Creating View to store data for later visualizations
Create View vaccination_rate as

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations as float)) OVER (partition by death.location Order by death.location, death.date) as rolling_count --Count to start over anytime it gets to a new location)
from Exploration_Portfolio_Project..covid_deaths as death
join Exploration_Portfolio_Project..covid_vaccinations as vacc
	on death.location = vacc.location
	and death.date = vacc.date

where death.continent is not null