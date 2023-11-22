--Select *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

Select Location,Date,total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Death
--Shows liklihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
from PortfolioProject..covidDeaths
WHERE Location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Show percentage of population got Covid

Select Location,Date,total_cases, population, new_cases, (total_cases/population)*100 as CasesPerPopulation
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2


--Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) AS HighestInfectionCount,(Max(total_cases)/population)*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY Location, population
ORDER BY PercentOfPopulationInfected desc


--Showing countries with Highest Death Count Per Population

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is NOT NULL
GROUP BY Location 
ORDER BY TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not NULL
AND iso_code <>  'OWID_LIC' 
AND iso_code <> 'OWID_HIC'
AND iso_code <> 'OWID_UMC'
AND iso_code <> 'OWID_LMC'
GROUP BY continent 
ORDER BY TotalDeathCount desc



--Global Numbers

Select date, sum(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths
, sum(cast(new_deaths as int))/sum (new_cases)*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent is not null
AND new_deaths <>0
AND new_cases <> 0
GROUP BY date
order by 1,2


--Looking at Total Population vs Vaccination

SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMP TABLE

DROP Table IF Exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
Select*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to Store Date for Later Visuals


--CREATE View PercentPopulationVaccinated AS
--SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
--, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent is not null

Select * 
FROM PercentPopulationVaccinated