Select *
From PortfolioProject..CovidDeaths$
Where continent is not null 
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations$	
--Order By 3,4

Select location, date, total_cases, new_cases, total_cases, population
From PortfolioProject..CovidDeaths$
Order By 1,2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Australia%'
Where continent is not null 
Order By 1,2

-- looking at Total Cases vs Population
-- shows what percentage of population got Covid

Select location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%Australia%'
Where continent is not null 
Order By 1,2



-- looking at Coutnries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%Australia%'
Where continent is not null 
Group by location, population
Order By PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%Australia%'
Where continent is not null 
Group by location
Order By TotalDeathCount desc




-- Breaking things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%Australia%'
Where continent is not null 
Group by continent
Order By TotalDeathCount desc


-- Showing the continents with the highest death count  per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%Australia%'
Where continent is not null 
Group by continent
Order By TotalDeathCount desc



-- Global Numbers 

Select SUM(new_cases) as total_cases, SUM( cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%Australia%'
Where continent is not null 
--Group by date 
Order By 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Order by 2,3 

-- Using CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--Order by 2,3 
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Temp Table

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
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--Order by 2,3 


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Drop table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--Order by 2,3 

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating Vew to store data for later visualisations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--Order by 2,3 

Select *
From PercentPopulationVaccinated

