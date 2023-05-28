
select *
from Project1..CovidDeaths
where continent is not null

select *
from Project1..CovidVaccinations

--Data chosen

select location, date, total_cases, new_cases, total_deaths, population
from Project1..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total death
--show likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project1..CovidDeaths
where location='Malaysia'
and continent is not null
order by 1,2

--Total cases vs Population
--Percentage of population infected with covid

select location, date,  population, total_cases, (total_cases/population)*100 as CasesPercentage
from Project1..CovidDeaths
--where location='Malaysia'
order by 1,2

--Country with highest infection rate compared to population

select location,population, max(total_cases) as HighestInfection, (max(total_cases)/population)*100 as PercentPopulationInfected
from Project1..CovidDeaths
--where location='Malaysia'
group by location, population
order by PercentPopulationInfected desc

--Countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from Project1..CovidDeaths
--where location='Malaysia'
where continent is not null
group by location
order by TotalDeathsCount desc

--Break things down by continent
--Continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from Project1..CovidDeaths
--where location='Malaysia'
where continent is not null
group by continent
order by TotalDeathsCount desc

--Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Project1..CovidDeaths
where continent is not null


--Total population vs Vaccinations
--Percentage of population that received at least one vaccine

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
 as RollingPeopleVaccinated
 --,(RollingPeolpeVaccinated/population)*100 
from Project1..CovidDeaths dea
join Project1..CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- CTE - calculation on partition by in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
 as RollingPeopleVaccinated
from Project1..CovidDeaths dea
join Project1..CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPercentage
from PopvsVac

--TEMP table - calculation on partition by in previous query

DROP table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
 as RollingPeopleVaccinated
from Project1..CovidDeaths dea
join Project1..CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as RollingPercentage
from #PercentagePopulationVaccinated

--Create view to store data visualization

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1 ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select*
From PercentagePopulationVaccinated