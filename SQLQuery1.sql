--select data that we are going to be using, Covid Death and Covid Vaccination Data is getting used for below queries

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2



--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
--where location like 'India'
order by 1,2



--looking at total cases vs the population
--shows what percentage of population got covid



select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like 'India'
order by 1,2



--looking at countries with highes infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
Group by location, population
--where location like 'India'
order by PercentPopulationInfected desc



--showing countries highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null -- because if not done like this the location gets mixed with the continent column where there are null values and considers the location as the continent, this makes unwanted calculations appear 
Group by location
--where location like 'India'
order by TotalDeathCount desc



--lets break things by continent
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null -- because if not done like this the location gets mixed with the continent column where there are null values and considers the location as the continent, this makes unwanted calculations appear 
Group by Location
--where location like 'India'
order by TotalDeathCount desc



--showing continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null -- because if not done like this the location gets mixed with the continent column where there are null values and considers the location as the continent, this makes unwanted calculations appear 
Group by continent
--where location like 'India'
order by TotalDeathCount desc



--Global Numbers
select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null 
--Group By date
order by 1,2



--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date= vac.date
order by 2,3



--USE CTE
With PopvsVac(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp Table
Drop table if exists #PercentPopulationVacinated
Create table #PercentPopulationVacinated
(
continet nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVacinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date= vac.date
--where dea.continent is not null
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVacinated


--creating view to store data later visualisations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated
