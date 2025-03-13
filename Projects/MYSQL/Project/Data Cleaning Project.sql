# Data Cleaning Project

Select *
from layoffs;

Select company, percentage_laid_off
from layoffs
order by percentage_laid_off desc
;

# 1. Remove Duplicates
# 2. Standardize the Data
# 3. Null & Blank Values
# 4. Remove Unnecessary Columns or Rows

Create Table layoffs_staging
Like layoffs;

Select *
from layoffs_staging;

Insert layoffs_staging
Select *
From layoffs;

Select *,
ROW_NUMBER () OVER (Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
from layoffs_staging;

With duplicate_cte as
(
Select *,
ROW_NUMBER () OVER (Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
from layoffs_staging
)
Select *
From duplicate_cte
Where Row_Num > 1;

# Deleting Duplicates using Create Table
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging_2
Select *,
ROW_NUMBER () OVER (Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
from layoffs_staging;

Select *
From layoffs_staging_2
WHERE Row_Num > 1;

SET SQL_SAFE_UPDATES = 0;

DELETE 
FROM layoffs_staging_2
WHERE Row_Num > 1;

# STANDARDIZING DATA

SELECT DISTINCT (TRIM(company))
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = (TRIM(company));

SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY 1;

SELECT *
FROM layoffs_staging_2
WHERE industry like '%crypto%';

UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry like '%crypto%';

SELECT DISTINCT COUNTRY, (TRIM(TRAILING '.' FROM country))
FROM layoffs_staging_2
ORDER BY 1;

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country like '%United States%';

SELECT DISTINCT COUNTRY
FROM layoffs_staging_2
ORDER BY 1;

SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` date;

SELECT *
FROM layoffs_staging_2;

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL
OR industry = ('');

SELECT *
FROM layoffs_staging_2
WHERE company = 'Airbnb';

UPDATE layoffs_staging_2
SET industry = 'Travel'
WHERE company = 'Airbnb';

UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';

SELECT ind1.industry, ind2.industry
FROM layoffs_staging_2 AS ind1
JOIN layoffs_staging_2 AS ind2
	ON ind1.company = ind2.company
    AND ind1.location = ind2.location
WHERE (ind1.industry IS NULL OR ind1.industry = '')
AND (ind2.industry IS NOT NULL OR ind2.industry != '');

UPDATE layoffs_staging_2 AS ind1
JOIN layoffs_staging_2 AS ind2
	ON ind1.company = ind2.company
    AND ind1.location = ind2.location
SET ind1.industry = ind2.industry
WHERE (ind1.industry IS NULL OR ind1.industry = '')
AND (ind2.industry IS NOT NULL OR ind2.industry != '');

SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging_2
DROP COLUMN Row_Num;

SELECT *
FROM layoffs_staging_2;