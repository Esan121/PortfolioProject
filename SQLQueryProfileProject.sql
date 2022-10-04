SELECT *
From Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--From Portfolio_Project..CovidVaccinations
--order by 3,4

--select data that is going to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2


--Total cases vs Totsl deaths

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Where location like '%states%'
order by 1,2

-- Total cases vs Population. Percentage of Pop that got Covid

Select Location, date, total_cases, new_cases, population, (total_cases/population)*100 as InvectedPercentage
From Portfolio_Project..CovidDeaths
Where location like '%states%'
order by 1,2

--Highest Infection rate in contrast with population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InvectedPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Group by population, location
order by InvectedPercentage desc

--Highest death count per CONTINENT

Select continent,  MAX(cast(Total_deaths as int)) as TotalDeathCounts
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCounts desc

--highest death count per population

Select continent,  MAX(cast(Total_deaths as int)) as TotalDeathCounts
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCounts desc

--global numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--Total Pop vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
	dea.date) as RollPeopleVacc
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollPeopleVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vaccinations,
	Sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
	dea.date) as RollPeopleVacc
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *
from PopvsVac

-- Checking New_vaccinations 

select continent, convert(int,new_vaccinations) as new_vaccinations
from Portfolio_Project..CovidVaccinations 
where new_vaccinations is not null
order by new_vaccinations desc

-- Creating view to store data for later visualizations

Create View #PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
	dea.date) as RollPeopleVacc
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3