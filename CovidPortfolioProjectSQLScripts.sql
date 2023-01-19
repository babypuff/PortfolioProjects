select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

--select * from PortfolioProject..CovidVaccinations
--order by 3,4 

-- select data we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths
-- Shows likelihood of dying you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, population,total_cases, (total_cases/population) * 100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection sRate compared to Population
select location, population,max(total_cases), max(total_cases/population) * 100 as PercentagePopulationInfected 
from PortfolioProject..CovidDeaths
-- where location like '%states%'
group by location, population
order by 4 desc


-- Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by location
order by 2 desc


-- Let's break things down by continent
select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is null
group by location
order by 2 desc


-- Global Numbers
select 
--date, 
sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage 
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated-- does sum of all new vac by that location, using order by will let the value added up based on order

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent  is not null
order by 2,3


-- use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated-- does sum of all new vac by that location, using order by will let the value added up based on order
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent  is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac


-- Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated-- does sum of all new vac by that location, using order by will let the value added up based on order
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
-- where dea.continent  is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
