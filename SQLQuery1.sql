Select * From PortfolioProject..CovidDeaths
Order BY 3,4

--Select * From PortfolioProject..CovidVacc
--Order BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order BY 1,2

-- Looking at total cases Vs total deaths
--Shows the death percentage in Tunisia
Select location, date, total_cases,total_deaths,
(CONVERT(float, total_deaths) / (CONVERT(float, total_cases) ))* 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
Where location like '%tunisia%'
order by 1,2

--Looking at total cases Vs Population
--Shows what percentage of population got Covid
Select location, date, total_cases,population,
(CONVERT(float, total_cases) / (CONVERT(float, population) ))* 100 AS CasesperPopulation
from PortfolioProject..CovidDeaths
Where location='France' and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select location, MAX(total_cases) as highestInfectionCount ,population,
MAX(CONVERT(float, total_cases) / (CONVERT(float, population) ))* 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- shows countries with highest death count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by TotalDeathcount desc

--Shows highset deathcount bu population By continent
Select location,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths
Where Location in('Europe','Africa','North America','South America','Asia','Oceania')
Group By Location
order by TotalDeathcount desc

--looking at total new vaccinations per date in canada 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location order by dea.date) as evolutionofNewVacc
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and dea.location='Canada'
order By 2,3


--WITH CTE

With POPvsVAC (Continent, location, Date, Population, New_vaccinations, evolutionofNewVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location order by dea.date) as evolutionofNewVacc
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and dea.location='Albania'
)
Select *, (evolutionofNewVacc/Population)*100 as PercentageOfVAaccPopulation
From  POPvsVAC 



-- CREATE VIEW

CREATE VIEW  PercentPopulationVaccinated as ( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location order by dea.date) as evolutionofNewVacc
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
)