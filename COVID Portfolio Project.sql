SELECT *
FROM PortfolioProject.. CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

-- SELECTING THE DATA THAT WE'RE GONNA USE

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject .. CovidDeaths
ORDER BY 1,2



--Looking at Total cases vs Total deaths
SELECT location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject .. CovidDeaths
--WHERE location = 'Egypt'
ORDER BY 1,2


--Looking at Total Cases Vs Population
--Shows percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationInfectionPercentage
FROM PortfolioProject .. CovidDeaths
--WHERE location = 'Egypt'
--WHERE location like '%states%'
ORDER BY 1,2



--Looking at countries with Highest infection rate Compared To Population
SELECT location, population, MAX(total_cases) AS HighestIfectionCount, MAX((total_cases/population)*100) AS InfectionPercentage
FROM PortfolioProject .. CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location,  MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject .. CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location,  MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject .. CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,SUM(CAST(new_deaths AS int))/
SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject .. CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at total Popualtion vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject.. CovidDeaths dea
 join PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
WITH PopVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject.. CovidDeaths dea
 join PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT* ,(RollingPeopleVaccinated/population)*100
FROM PopVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject.. CovidDeaths dea
 join PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated / population)*100
FROM #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject.. CovidDeaths dea
 join PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated
