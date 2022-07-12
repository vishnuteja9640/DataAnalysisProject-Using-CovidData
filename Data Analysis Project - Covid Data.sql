use PortfolioProjects;
-- Here first it will order by 3 then, if they have the same location then it check and order by 4th column
select * from dbo.CovidDeaths order by 3,4;

select * from dbo.CovidVaccinations order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population from dbo.CovidDeaths order by 1,2;

--Now consider Total cases vs Total Deaths
--Here we created a new column by name Death Percentage using calculations made on existing columns
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'Death Percentage' from dbo.covidDeaths order by 1,2;

--If we want to search by location specific example United States
--shows likelihood of dying if one gets covid in a specific country(United states)
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'Death Percentage' from dbo.covidDeaths where location 
like '%states%' order by 1,2;


--Now we look at the total cases vs population
select location,date,total_cases,population from dbo.CovidDeaths;

--Now calculating the percentage of the entire population got Covid in United States
select location,date,total_cases,population,(total_cases/population)*100 as 'Percentage of Population Infected' from dbo.CovidDeaths where location 
like '%states%' order by 1,2;

--Now calculating the percentage of the entire population got Covid by country
select location,date,total_cases,population,(total_cases/population)*100 as 'Percentage of Population Infected' from dbo.CovidDeaths order by 1,2;

--Looking at Countries with Highest Infection Rate Compared to Population
select location,max(total_cases),population,max((total_cases/population))*100 as 'Percentage of Population Infected' from dbo.CovidDeaths group by 
location,population order by 'Percentage of Population Infected' desc;

--The GROUP BY clause is typically used alongside aggregate functions, which are count,avg,min,max,sum others.

-- If we want to calculate countries with highest Death Count per population
-- If we see in the columns section Total_Deaths column is a nvchar datatype so we to typecast it.

select location,max(cast(total_deaths as int)) as 'Total_deaths' from dbo.CovidDeaths group by location order by 'Total_deaths' desc;

--- The above code has some rows like world, and some other columns which we do not need as of now. 
--- SO, the modified code would be
select location,max(cast(total_deaths as int)) as 'Total_deaths' from dbo.CovidDeaths where continent is not null group by location 
order by 'Total_deaths' desc;


-- If we want to break up the total deaths by continent
select continent,max(cast(total_deaths as int)) as 'Total_deaths' from dbo.CovidDeaths where continent is not null
group by continent order by 'Total_deaths' desc;

--select location,max(cast(total_deaths as int)) as 'Total_deaths' from dbo.CovidDeaths where continent is null group by location order by 'Total_deaths' desc;

-- Now if we want to calculate the total number of new cases on a particular day across the world

select date,sum(new_cases) as 'Daily Covid Cases Globally' from dbo.CovidDeaths where continent is not null group by date order by 1,2;

--Now if we want to calculate the total number of deaths and total new covid cases on a specific date across the world

select date,sum(new_cases) as 'Daily Covid Cases Globally', sum(cast(new_deaths as int)) as 'Daily Covid Deaths Globally', 
sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death_percentage' from dbo.CovidDeaths where continent is not null group by date order by date

-- Till date how many people died of Covid Globally
select sum(new_cases) as 'Daily Covid Cases Globally', sum(cast(new_deaths as int)) as 'Daily Covid Deaths Globally', 
sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death_percentage' from dbo.CovidDeaths where continent is not null;


---Now Covid Vaccinations data
select * from dbo.CovidVaccinations;

--Join the two tables Covid Vaccinations and Covid Deaths on location and date
-- Here to join two tables on some third equality it is better if we use and instead of ,
select * from dbo.CovidDeaths join dbo.CovidVaccinations on dbo.CovidDeaths.location = dbo.CovidVaccinations.location 
and dbo.CovidDeaths.date=dbo.CovidVaccinations.date;


-- Now looking at how many people got vaccinated out of the entire population
-- If the tables name is long enough you can use the aliases to use it in a short way

-- Per day Vaccinations when compared with total populations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from dbo.CovidDeaths as dea 
join dbo.CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date where dea.continent is not null order by 2,3;

--Before we have calculated the daily vaccinations we will partition by location
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location)
from dbo.CovidDeaths as dea join dbo.CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date where dea.continent is not null order by 2,3;

--But here in the new_vaccinations column some elements which were not null are not adding up so
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as 'Live status of Vaccinated People' 
from dbo.CovidDeaths as dea join dbo.CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date where dea.continent is not null order by 2,3;


-- Now checking how many people in the country got Vaccinated
-- You can't use the alias which you had just created so you have to use the column name only 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as 'Live status of Vaccinated People',
cast(vac.new_vaccinations as bigint)/(dea.population)*100 'Percentage of Vaccinated People' 
from dbo.CovidDeaths as dea join dbo.CovidVaccinations as vac on dea.location = vac.location
and dea.date = vac.date and dea.continent is not null order by 2,3;

-- You can also create view so that you can visualize the table in tableau
