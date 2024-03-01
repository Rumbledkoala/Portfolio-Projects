SELECT *
FROM PortfolioProject..CovidDeaths

SELECT location, date, population, total_cases, total_deaths, new_cases
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

select PortfolioProject..CovidDeaths

SELECT suser_sname(owner_sid) AS [Database Owner] FROM sys.databases WHERE name = 'PortfolioProject';

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN total_cases FLOAT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN total_cases FLOAT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN total_deaths FLOAT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN total_cases_per_million FLOAT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN total_deaths_per_million FLOAT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN reproduction_rate FLOAT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN icu_patients INT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN icu_patients_per_million FLOAT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN hosp_patients INT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN hosp_patients_per_million FLOAT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN weekly_hosp_admissions INT

ALTER TABLE PortfolioProject.dbo.CovidDeaths ALTER COLUMN weekly_hosp_admissions_per_million FLOAT

/* COVID DEATH DATA EXPLORATION */

--Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%United Kingdom%'
AND continent IS NOT NULL
ORDER BY 1,2

--Demonstrates the likelihood of death from covid in each country

--Total Cases vs Population

SELECT location, population, total_cases, ROUND((total_cases/population)*100, 2) AS 'Cases by Population'
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT date, location, population, total_cases, ROUND((total_cases/population)*100, 2) AS 'Cases by Population'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%United Kingdom%'
ORDER BY 1 DESC

--Displays the affected population as a %age

SELECT population, ROUND(MAX((total_cases/population))*100, 2) AS Cases_by_Population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--AND location LIKE '%China%'
GROUP BY population
ORDER BY Cases_by_Population DESC

SELECT date, location, population, total_cases, ROUND((total_cases/population)*100, 2) AS 'Cases by Population'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1 DESC

--Looking at highest infected population rate based on country

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(ROUND((total_cases/population)*100, 2)) AS Percentage_by_Population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

--Showing Countries with Highest Death Count per Population

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Highest_Death_Count DESC

--Breaking things down by continent

--Looking at continents with highest death count

SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--Breaking things down by country

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX(ROUND((total_cases/population)*100, 2)) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Brunei%'
GROUP BY location, population
ORDER BY PercentPopulationInfected

--Looking at countries with highest death count per population

SELECT location, population, MAX(total_deaths) AS HighestDeathCount, 
MAX(ROUND((total_deaths/population)*100, 2)) AS PercentPopulationDead
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Peru%'
AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationDead

--Total cases vs population
--shows what percentage of population got covid

SELECT location, population, MAX(total_cases) AS Total_Cases, ROUND(MAX((total_cases/population))*100, 2) AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

--Total cases vs total deaths
--shows likelihood of dying from covid by country

SELECT location, population, MAX(total_deaths) AS Total_Deaths, 
MAX(total_cases) AS Total_Cases, 
ROUND(MAX((Total_Deaths/Total_Cases))*100, 2) AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--AND location like '%United Kingdom%'
GROUP BY location, population
ORDER BY Death_Percentage DESC

--showing highest death count per continent

SELECT continent, MAX(total_deaths) AS Total_Deaths, 
ROUND(MAX((total_deaths/population))*100, 2) AS Highest_Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Percentage DESC

--GLOBAL NUMBERS

SELECT date AS Date, SUM(NULLIF(new_cases, 0)) AS Total_New_Cases, 
SUM(NULLIF(new_deaths, 0)) AS Total_New_Deaths, 
(SUM(NULLIF(new_deaths, 0))/SUM(NULLIF(new_cases, 0))*100) AS Total_Death_Percentage
FROM PortfolioProject..CovidDeaths
GROUP BY date
HAVING SUM(NULLIF(new_deaths, 0)) IS NOT NULL
AND SUM(NULLIF(new_cases, 0)) IS NOT NULL
ORDER BY Total_Death_Percentage DESC

--Looking at total population vs vaccinations

SELECT deaths.date, deaths.continent, deaths.location, deaths.population, 
vaccs.people_vaccinated, MAX(ROUND((CONVERT(FLOAT, (vaccs.people_vaccinated/deaths.population)))*100, 2)) 
OVER (PARTITION BY deaths.location
ORDER BY deaths.location, deaths.date) AS Percentage_Population_Vaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
	AND vaccs.people_vaccinated IS NOT NULL
WHERE deaths.continent IS NOT NULL
AND vaccs.continent IS NOT NULL 
ORDER BY Percentage_Population_Vaccinated DESC

--Using CTE

WITH PopvsVacc (continent, location, date, population, people_vaccinated, Percentage_People_Vaccinated)
AS (
SELECT deaths.date, deaths.continent, deaths.location, deaths.population, 
vaccs.people_vaccinated, MAX(ROUND((CONVERT(FLOAT, (vaccs.people_vaccinated/deaths.population)))*100, 2)) 
OVER (PARTITION BY deaths.location
ORDER BY deaths.location, deaths.date) AS Percentage_People_Vaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
	AND vaccs.people_vaccinated IS NOT NULL
WHERE deaths.continent IS NOT NULL
AND vaccs.continent IS NOT NULL 
--ORDER BY Percentage_People_Vaccinated DESC
)
SELECT *, ROUND((Percentage_People_Vaccinated/population)*100, 2) AS Percentage_Population_Vaccinated
FROM PopvsVacc
ORDER BY Percentage_Population_Vaccinated DESC

--Using Temp Tables

DROP TABLE IF EXISTS #Percent_People_Vaccinated
CREATE TABLE #Percent_People_Vaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date nvarchar(255), 
population INT, 
people_vaccinated INT, 
Percentage_Population_Vaccinated FLOAT
)

INSERT INTO	#Percent_People_Vaccinated
SELECT deaths.date, deaths.continent, deaths.location, deaths.population, 
vaccs.people_vaccinated, MAX(ROUND((CONVERT(FLOAT, (vaccs.people_vaccinated/deaths.population)))*100, 2)) 
OVER (PARTITION BY deaths.location
ORDER BY deaths.location, deaths.date) AS Percentage_People_Vaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
	AND vaccs.people_vaccinated IS NOT NULL
WHERE deaths.continent IS NOT NULL
AND vaccs.continent IS NOT NULL 
ORDER BY Percentage_People_Vaccinated DESC

SELECT *, (Percentage_Population_Vaccinated/population)*100
FROM #Percent_People_Vaccinated

--Creating View to store data for later visualisations

CREATE VIEW Percentage_People_Vaccinated AS
SELECT deaths.date, deaths.continent, deaths.location, deaths.population, 
vaccs.people_vaccinated, 
MAX(ROUND((CONVERT(FLOAT, (vaccs.people_vaccinated/deaths.population)))*100, 2)) 
OVER (PARTITION BY deaths.location
ORDER BY deaths.location, deaths.date) AS Percentage_People_Vaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
	AND vaccs.people_vaccinated IS NOT NULL
WHERE deaths.continent IS NOT NULL
AND vaccs.continent IS NOT NULL 
--ORDER BY Percentage_People_Vaccinated DESC

SELECT *
FROM Percentage_People_Vaccinated