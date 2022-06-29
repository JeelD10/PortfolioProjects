Select *
From PortfolioProject..CovidDeaths
Order By 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

---Selecting the attributes which are necessary for further use
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths 
where continent is not null
Order By 1,2

--Quick glance at Total Cases vs Total Deaths
-- Shows the chances of dying due to covid in particular location (India in this case)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
where location like '%india%' AND continent is not null
Order By 1,2

--Quick glance at Total Cases vs Population
--Demonstrates the percentage of population got covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths 
where location like '%india%'
Order By 1,2

--Observing the countries with highest infection
Select Location, MAX(total_cases) as HighestInfection , Population, MAX((total_cases/population))*100 as CovidPercentage
From PortfolioProject..CovidDeaths 
--where location like '%india%'
Group By location, population
Order By  CovidPercentage DESC 

--Observing the highest deaths
Select Location, MAX(cast (total_deaths as int)) as DeathCount
From PortfolioProject..CovidDeaths 
--where location like '%india%'
where continent is not null
Group By location
Order By  DeathCount DESC 

--Observing the highest deaths by CONTINENT
Select continent, MAX(cast (total_deaths as int)) as DeathCount
From PortfolioProject..CovidDeaths 
--where location like '%india%'
where continent is not null
Group By continent
Order By  DeathCount DESC 


---Looking at the total numbers (Globally) (Not for particular country or continent)
Select date, SUM(new_cases) as TotalNewCases, SUM(cast (new_deaths as int)) as TotalNewDeaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100   as DesathPercentage
From PortfolioProject..CovidDeaths 
where continent is not null
Group By date 
Order By 1,2

--Looking at total cases
Select SUM(new_cases) as TotalNewCases, SUM(cast (new_deaths as int)) as TotalNewDeaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100   as DesathPercentage
From PortfolioProject..CovidDeaths 
where continent is not null
Order By 1,2


--Quick glance at the Total Population vs Vaccinations
---Joining CovidDeaths and CovidVaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated

from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated

from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


---TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated

from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
---order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated

from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3