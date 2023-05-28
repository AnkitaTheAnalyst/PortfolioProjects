/*

COVID 19 DATA EXPLORATION

Skill Used: Joins, CTE's, Temp Tables, Window functions, Aggregate Functions, Creating Views, Converting Data Types

*/



USE portfolio_project


SELECT *
FROM coviddeaths_csv
WHERE continent is not null
ORDER BY continent, location


--Select data that we are going to be starting with


SELECT Location, 
       date, 
	   total_cases, 
	   new_cases, 
	   total_deaths, 
	   population
FROM     coviddeaths_csv
WHERE  (Continent IS NOT NULL)
ORDER BY Location, date


--Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, 
       date, 
	   total_cases, 
	   total_deaths, 
	   CONVERT(DECIMAL(15, 3), total_cases) / CONVERT(DECIMAL(15, 3), total_deaths) * 100 AS death_percentage
FROM     coviddeaths_csv
WHERE  (Location LIKE '%states%') AND (Continent IS NOT NULL)
ORDER BY Location, date



--Looking at Total Cases Vs Population
--Shows what percentage of population got covid

SELECT Location, 
       date, 
	   Population, 
	   total_cases, 
	   (CONVERT (DECIMAL(15,3),total_cases)/population)*100 as PercentPopulationInfected
FROM coviddeaths_csv
WHERE location like '%states%'AND Continent is not Null
ORDER BY Location, date




--Looking at countries with Highest Infection Rate compared to Population

SELECT Location, 
       Population, 
	   max(total_cases) AS Highestinfectioncount, 
	   max((CONVERT (DECIMAL(15,3),
	   total_cases)/population))*100 as PercentPopulationInfected
FROM coviddeaths_csv
WHERE Continent is not Null
GROUP BY Location, population
ORDER BY PercentPopulationInfected Desc





--Showing Countries with Highest Death Count per Population 

SELECT location, 
       max(cast(total_deaths as int)) AS Totaldeathcount
FROM coviddeaths_csv
WHERE continent is Null
GROUP BY Location
ORDER BY Totaldeathcount Desc



--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the Highest death count per population


SELECT continent, 
       max(cast(total_deaths as int)) AS Totaldeathcount
FROM coviddeaths_csv
WHERE continent is not Null
GROUP BY continent
ORDER BY Totaldeathcount Desc




--Global Numbers


SELECT Sum(CONVERT(Decimal(15,3),New_cases)) AS Total_cases, 
       Sum(CONVERT(Decimal(15,3),New_deaths)) AS Total_deaths, 
       Sum(CONVERT(Decimal(15,3),New_deaths))/Sum(CONVERT(Decimal(15,3),New_cases))*100 As DeathPercentage
FROM coviddeaths_csv
WHERE Continent is not Null
ORDER BY 1,2



--Looking at total population Vs Vaccinations
--Shows Percentage of Population that has received at least one covid vaccine



WITH Popvsvac (Continent, Location, Date, Population, New_vaccinations, Rollingpeoplevaccinated) AS

(
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
FROM coviddeaths_csv dea
JOIN covidvaccinations_csv vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (Rollingpeoplevaccinated/Population)*100
FROM Popvsvac




--TEMP TABLE 


DROP TABLE if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population Numeric,
newvaccinations numeric,
Rollingpeoplevaccinated numeric
)



INSERT INTO #Percentpopulationvaccinated
SELECT dea.continent,
       dea.location,
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM coviddeaths_csv dea
JOIN covidvaccinations_csv vac
ON dea.location = vac.location
AND dea.date = vac.date


SELECT *, (Rollingpeoplevaccinated/Population)*100
FROM #Percentpopulationvaccinated




--Creating view to store data for later visualizations



CREATE VIEW Percentpopulationvaccinated AS
SELECT dea.continent,
       dea.location,
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM coviddeaths_csv dea
JOIN covidvaccinations_csv vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null




