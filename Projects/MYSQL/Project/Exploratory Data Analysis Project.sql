# Exploratory Data Analysis

SELECT *
FROM layoffs_staging_2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2;

SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off desc;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`DATE`), MAX(`DATE`)
FROM layoffs_staging_2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR (`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR (`date`)
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;

# ROLLING LAYOFFS BY MONTH
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS `Total_Off`
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, Total_Off, SUM(Total_Off) OVER(ORDER BY `MONTH`) AS rolling_Total
FROM Rolling_Total;

WITH Rolling_Total AS 
(
SELECT company, SUBSTRING(`date`,1,4) AS `YEAR`, SUM(total_laid_off) AS `Total_Off`
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,4) IS NOT NULL
GROUP BY company, `YEAR`
ORDER BY 3 DESC
)
SELECT company, `YEAR`, Total_Off, SUM(Total_Off) OVER(ORDER BY `YEAR`) AS rolling_Total
FROM Rolling_Total;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
ORDER BY Ranking ASC;

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS 
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
ORDER BY years ASC
)
SELECT *
FROM (Company_Year_Rank)
WHERE RANKING <= 5;
