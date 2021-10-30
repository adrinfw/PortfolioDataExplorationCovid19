-- Eksplorasi tabel kematian covid
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- SELECT DATA YANG AKAN KITA GUNAKAN
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Melihat total kasus dan total kematian keseluruhan
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
order by 1,2


-- Melihat total kasus dan total kematian di Indonesia
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
where location like '%Indonesia%'
order by 1,2


-- Melihat populasi dan total kasus
-- Persentase yang terpapar covid
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
order by 1,2


-- Melihat populasi dan total kasus dan persentase terpapar covid di Indonesia atau di negara manapun
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
-- where location = 'Indonesia'
order by 1,2


-- Melihat data infeksi tertinggi terhadap populasi
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by InfectedPercentage desc


-- Melihat data infeksi tertinggi terhadap populasi di negara tertentu
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where location = 'Indonesia' and continent is not null
group by location, population
order by 1,2


-- Melihat data kematian tertinggi di setiap negara
select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc
-- Hasil yang ditampilkan belum akurat karena tipe data kolom total_death 
-- digunakan masih berbentuk varchar, maka tipe data tersebut lebih baik diganti menjadi INT


-- Mengubah tipe data VARCHAR menjadi INT pada kolom total_death
-- sekaligus menampilkan kembali angka kematian tertinggi di setiap negara
select location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- Melihat data kematian tertinggi untuk negara tertentu
select location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Indonesia' and continent is not null
group by location
order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT


-- Melihat data kematian berdasarkan continent
select continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc
-- Hasil yang ditampilkan tidak akurat karena dalam kolom continent
-- tidak menghitung semua angka seperti pada kolom location


-- Masih sama seperti di atas, akan kolom continent diganti dengan
-- kolom location
select location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

-- Melihat angka kematian berdasarkan waktu dan total yang terinfeksi 
select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Melihat persentase angka kematian secara keseluruhan
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths,
SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Eksplorasi tabel vaksinasi
-- Total Populasi VS Vaksinasi
-- Melihat Persentase 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Menggunakan CTE untuk perhitungan berdasarkan query sebelumnya

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Menggunakan Temp Table untuk perhitungan dengan Partition by berdasarkan query sebelumnya

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Membuat Views baru untuk visualisasi berikutnya

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 