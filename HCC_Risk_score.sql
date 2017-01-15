-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aryasomayajula, Arun
-- Create date: 01/10/2017
-- Description:	sproc to create HCC risk scores for Community/Instituitional/New Enrollee models from CMS
-- =============================================

--drop procedure dbo.uspVariableMatrix_20
CREATE PROCEDURE [dbo].[usp_HCCRiskScores]
    (
      @HCCBatchID BIGINT ,
      @HealthPlanID SMALLINT ,
	  @HCCCoefYear SMALLINT,
      @FromDate DATETIME ,
      @ToDate DATETIME       
    )
AS
    BEGIN
        SET NOCOUNT ON;

SELECT DISTINCT 
  b.GlobalMemberID,
  b.HealthPlanID,
  b.Sex,
  e.LineOfBusinessID,
  0                                           AS OREC,
  0                                           AS NEW_ENROLLEE,
  0                                           AS MCAID,
  min(e.EligibilityFromDate)                  AS minEligibilityFromDate,
  max(e.EligibilityToDate)                    AS maxEligibilityFromDate,
  datediff(YEAR, b.DateOfBirth, @ToDate) AS Age,
  b.MemberID
INTO #temp_cohort_for_HCC_risk
FROM (SELECT *
      FROM ODS.dbo.vwMemberBio where HealthPlanID=@HealthPlanID) b
  JOIN (SELECT *
        FROM ODS.dbo.Eligibility) e
    ON b.MemberID = e.MemberID
WHERE b.HealthPlanID IN (11) AND b.DateOfDeath IS NULL AND b.Sex IS NOT NULL
GROUP BY b.GlobalMemberID, b.HealthPlanID, e.LineOfBusinessID, b.DateOfBirth, b.MemberID, b.Sex

SELECT
  x.*,
  CASE WHEN (x.Age < 65 AND x.OREC <> 0)
    THEN 1
  ELSE 0 END AS DISABL,
  CASE WHEN (x.OREC = 0 AND x.age >= 65)
    THEN 1
  ELSE 0 END AS ORIGDS
INTO #temp_cohort1_for_HCC_risk
FROM #temp_cohort_for_HCC_risk x;

-- Get diagnosis for all the patients.

SELECT
  vmb.GlobalMemberID,
  cdg.DiagnosisVersion,
  cdg.DiagnosisCode,
  cdg.DiagnosisID,
  cdg.DiagnosisSequence,
  icd9hcc.HCCCode  AS HCC2ICD9,
  icd10hcc.HCCCode AS HCC2ICD10

INTO #temp_diagnosis_for_HCC_risk
FROM ods..ClaimDiagnosis cdg
  JOIN ods..ClaimMaster cm ON cm.ClaimMasterID = cdg.ClaimMasterID
  JOIN #temp_cohort_for_HCC_risk vmb ON vmb.MemberID = cm.MemberID
  LEFT JOIN Junk..CMS2016ICD9ToHCC icd9hcc ON cdg.DiagnosisCode = icd9hcc.ICD9Code
  LEFT JOIN Junk..CMS2016ICD10ToHCC icd10hcc ON cdg.DiagnosisCode = icd10hcc.ICD10Code
WHERE cm.ServiceDateTo BETWEEN @FromDate AND @ToDate

-- create Age and demographics variables

SELECT
  schr.GlobalMemberID,
  schr.Age   AS AGEF,
  schr.Sex   AS SEX,
  CASE
  WHEN schr.Age >= 0 AND schr.Age <= 34 AND schr.Sex = 'F'
    THEN 1
  WHEN (schr.Age > 34 AND schr.Age <= 44 AND schr.Sex = 'F')
    THEN 2
  WHEN (schr.Age > 44 AND schr.Age <= 54 AND schr.Sex = 'F')
    THEN 3
  WHEN (schr.Age > 54 AND schr.Age <= 59 AND schr.Sex = 'F')
    THEN 4
  WHEN (schr.Age > 59 AND schr.Age <= 64 AND schr.Sex = 'F')
    THEN 5
  WHEN (schr.Age > 64 AND schr.Age <= 69 AND schr.Sex = 'F')
    THEN 6
  WHEN (schr.Age > 69 AND schr.Age <= 74 AND schr.Sex = 'F')
    THEN 7
  WHEN (schr.Age > 74 AND schr.Age <= 79 AND schr.Sex = 'F')
    THEN 8
  WHEN (schr.Age > 79 AND schr.Age <= 84 AND schr.Sex = 'F')
    THEN 9
  WHEN (schr.Age > 84 AND schr.Age <= 89 AND schr.Sex = 'F')
    THEN 10
  WHEN (schr.Age > 89 AND schr.Age <= 94 AND schr.Sex = 'F')
    THEN 11
  WHEN (schr.Age > 94 AND schr.Sex = 'F')
    THEN 12
  WHEN (schr.Age >= 0 AND schr.Age <= 34 AND schr.Sex = 'M')
    THEN 13
  WHEN (schr.Age > 34 AND schr.Age <= 44 AND schr.Sex = 'M')
    THEN 14
  WHEN (schr.Age > 44 AND schr.Age <= 54 AND schr.Sex = 'M')
    THEN 15
  WHEN (schr.Age > 54 AND schr.Age <= 59 AND schr.Sex = 'M')
    THEN 16
  WHEN (schr.Age > 59 AND schr.Age <= 64 AND schr.Sex = 'M')
    THEN 17
  WHEN (schr.Age > 64 AND schr.Age <= 69 AND schr.Sex = 'M')
    THEN 18
  WHEN (schr.Age > 69 AND schr.Age <= 74 AND schr.Sex = 'M')
    THEN 19
  WHEN (schr.Age > 74 AND schr.Age <= 79 AND schr.Sex = 'M')
    THEN 20
  WHEN (schr.Age > 79 AND schr.Age <= 84 AND schr.Sex = 'M')
    THEN 21
  WHEN (schr.Age > 84 AND schr.Age <= 89 AND schr.Sex = 'M')
    THEN 22
  WHEN (schr.Age > 89 AND schr.Age <= 94 AND schr.Sex = 'M')
    THEN 23
  WHEN (schr.Age > 94 AND schr.Sex = 'M')
    THEN 24
  ELSE NULL END "_AGESEX",

  CASE
  WHEN (schr.Age >= 0 AND schr.Age <= 34 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  WHEN (schr.Age > 34 AND schr.Age <= 44 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 2
  WHEN (schr.Age > 44 AND schr.Age <= 54 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 3
  WHEN (schr.Age > 54 AND schr.Age <= 59 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 4
  WHEN (schr.Age > 59 AND schr.Age <= 63 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 5
  WHEN (schr.Age = 64 AND schr.Sex = 'F' AND schr.OREC <> 0 AND schr.NEW_ENROLLEE = 1)
    THEN 5
  WHEN (schr.Age = 64 AND schr.Sex = 'F' AND schr.OREC = 0 AND schr.NEW_ENROLLEE = 1)
    THEN 6
  WHEN (schr.Age = 65 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 6
  WHEN (schr.Age = 66 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 7
  WHEN (schr.Age = 67 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 8
  WHEN (schr.Age = 68 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 9
  WHEN (schr.Age = 69 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 10
  WHEN (schr.Age > 69 AND schr.Age <= 74 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 11
  WHEN (schr.Age > 74 AND schr.Age <= 79 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 12
  WHEN (schr.Age > 79 AND schr.Age <= 84 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 13
  WHEN (schr.Age > 84 AND schr.Age <= 89 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 14
  WHEN (schr.Age > 89 AND schr.Age <= 94 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 15
  WHEN (schr.Age > 94 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 16

  WHEN (schr.Age >= 0 AND schr.Age <= 34 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 17
  WHEN (schr.Age > 34 AND schr.Age <= 44 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 18
  WHEN (schr.Age > 44 AND schr.Age <= 54 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 19
  WHEN (schr.Age > 54 AND schr.Age <= 59 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 20
  WHEN (schr.Age > 59 AND schr.Age <= 63 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 21
  WHEN (schr.Age = 64 AND schr.Sex = 'M' AND schr.OREC <> 0 AND schr.NEW_ENROLLEE = 1)
    THEN 21
  WHEN (schr.Age = 64 AND schr.Sex = 'M' AND schr.OREC = 0 AND schr.NEW_ENROLLEE = 1)
    THEN 22
  WHEN (schr.Age = 65 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 22
  WHEN (schr.Age = 66 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 23
  WHEN (schr.Age = 67 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 24
  WHEN (schr.Age = 68 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 25
  WHEN (schr.Age = 69 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 26
  WHEN (schr.Age > 69 AND schr.Age <= 74 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 27
  WHEN (schr.Age > 74 AND schr.Age <= 79 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 28
  WHEN (schr.Age > 79 AND schr.Age <= 84 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 29
  WHEN (schr.Age > 84 AND schr.Age <= 89 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 30
  WHEN (schr.Age > 89 AND schr.Age <= 94 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 31
  WHEN (schr.Age > 94 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 32
  ELSE NULL END "NE_AGESEX",
  CASE WHEN (schr.Age >= 0 AND schr.Age <= 34 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F0_34,
  CASE WHEN (schr.Age > 34 AND schr.Age <= 44 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F35_44,
  CASE WHEN (schr.Age > 44 AND schr.Age <= 54 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F45_54,
  CASE WHEN (schr.Age > 54 AND schr.Age <= 59 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F55_59,
  CASE WHEN (schr.Age > 59 AND schr.Age <= 64 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F60_64,
  CASE WHEN (schr.Age > 64 AND schr.Age <= 69 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F65_69,
  CASE WHEN (schr.Age > 69 AND schr.Age <= 74 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F70_74,
  CASE WHEN (schr.Age > 74 AND schr.Age <= 79 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F75_79,
  CASE WHEN (schr.Age > 79 AND schr.Age <= 84 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F80_84,
  CASE WHEN (schr.Age > 84 AND schr.Age <= 89 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F85_89,
  CASE WHEN (schr.Age > 89 AND schr.Age <= 94 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F90_94,
  CASE WHEN (schr.Age > 94 AND schr.Sex = 'F')
    THEN 1
  ELSE 0 END AS F95_GT,
  CASE WHEN (schr.Age >= 0 AND schr.Age <= 34 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M0_34,
  CASE WHEN (schr.Age > 34 AND schr.Age <= 44 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M35_44,
  CASE WHEN (schr.Age > 44 AND schr.Age <= 54 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M45_54,
  CASE WHEN (schr.Age > 54 AND schr.Age <= 59 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M55_59,
  CASE WHEN (schr.Age > 59 AND schr.Age <= 64 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M60_64,
  CASE WHEN (schr.Age > 64 AND schr.Age <= 69 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M65_69,
  CASE WHEN (schr.Age > 69 AND schr.Age <= 74 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M70_74,
  CASE WHEN (schr.Age > 74 AND schr.Age <= 79 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M75_79,
  CASE WHEN (schr.Age > 79 AND schr.Age <= 84 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M80_84,
  CASE WHEN (schr.Age > 84 AND schr.Age <= 89 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M85_89,
  CASE WHEN (schr.Age > 89 AND schr.Age <= 94 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M90_94,
  CASE WHEN (schr.Age > 94 AND schr.Sex = 'M')
    THEN 1
  ELSE 0 END AS M95_GT,
  CASE WHEN (schr.Age >= 0 AND schr.Age <= 34 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF0_34,
  CASE WHEN (schr.Age > 34 AND schr.Age <= 44 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF35_44,
  CASE WHEN (schr.Age > 44 AND schr.Age <= 54 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF45_54,
  CASE WHEN (schr.Age > 54 AND schr.Age <= 59 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF55_59,
  CASE WHEN (schr.Age > 59 AND schr.Age <= 64 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF60_64,
  CASE WHEN (schr.Age = 65 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF65,
  CASE WHEN (schr.Age = 66 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF66,
  CASE WHEN (schr.Age = 67 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF67,
  CASE WHEN (schr.Age = 68 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF68,
  CASE WHEN (schr.Age = 69 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF69,
  CASE WHEN (schr.Age > 69 AND schr.Age <= 74 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF70_74,
  CASE WHEN (schr.Age > 74 AND schr.Age <= 79 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF75_79,
  CASE WHEN (schr.Age > 79 AND schr.Age <= 84 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF80_84,
  CASE WHEN (schr.Age > 84 AND schr.Age <= 89 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF85_89,
  CASE WHEN (schr.Age > 89 AND schr.Age <= 94 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF90_94,
  CASE WHEN (schr.Age > 94 AND schr.Sex = 'F' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEF95_GT,
  CASE WHEN (schr.Age >= 0 AND schr.Age <= 34 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM0_34,
  CASE WHEN (schr.Age > 34 AND schr.Age <= 44 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM35_44,
  CASE WHEN (schr.Age > 44 AND schr.Age <= 54 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM45_54,
  CASE WHEN (schr.Age > 54 AND schr.Age <= 59 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM55_59,
  CASE WHEN (schr.Age > 59 AND schr.Age <= 63 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM60_64,
  CASE WHEN (schr.Age = 65 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM65,
  CASE WHEN (schr.Age = 66 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM66,
  CASE WHEN (schr.Age = 67 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM67,
  CASE WHEN (schr.Age = 68 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM68,
  CASE WHEN (schr.Age = 69 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM69,
  CASE WHEN (schr.Age > 69 AND schr.Age <= 74 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM70_74,
  CASE WHEN (schr.Age > 74 AND schr.Age <= 79 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM75_79,
  CASE WHEN (schr.Age > 79 AND schr.Age <= 84 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM80_84,
  CASE WHEN (schr.Age > 84 AND schr.Age <= 89 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM85_89,
  CASE WHEN (schr.Age > 89 AND schr.Age <= 94 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM90_94,
  CASE WHEN (schr.Age > 94 AND schr.Sex = 'M' AND schr.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END AS NEM95_GT

INTO #temp_demo_for_HCC_risk
FROM #temp_cohort_for_HCC_risk schr

-- create diagnosis,HCC and interaction variables

;WITH x AS (
    SELECT
      sdfhr.GlobalMemberID,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 1 OR sdfhr.HCC2ICD10 = 1)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC1,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 2 OR sdfhr.HCC2ICD10 = 2)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC2,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 6 OR sdfhr.HCC2ICD10 = 6)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC6,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 8 OR sdfhr.HCC2ICD10 = 8)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC8,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 9 OR sdfhr.HCC2ICD10 = 9)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC9,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 10 OR sdfhr.HCC2ICD10 = 10)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC10,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 11 OR sdfhr.HCC2ICD10 = 11)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC11,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 12 OR sdfhr.HCC2ICD10 = 12)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC12,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 17 OR sdfhr.HCC2ICD10 = 17)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC17,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 18 OR sdfhr.HCC2ICD10 = 18)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC18,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 19 OR sdfhr.HCC2ICD10 = 19)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC19,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 21 OR sdfhr.HCC2ICD10 = 21)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC21,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 22 OR sdfhr.HCC2ICD10 = 22)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC22,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 23 OR sdfhr.HCC2ICD10 = 23)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC23,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 27 OR sdfhr.HCC2ICD10 = 27)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC27,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 28 OR sdfhr.HCC2ICD10 = 28)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC28,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 29 OR sdfhr.HCC2ICD10 = 29)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC29,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 33 OR sdfhr.HCC2ICD10 = 33)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC33,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 34 OR sdfhr.HCC2ICD10 = 34)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC34,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 35 OR sdfhr.HCC2ICD10 = 35)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC35,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 39 OR sdfhr.HCC2ICD10 = 39)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC39,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 40 OR sdfhr.HCC2ICD10 = 40)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC40,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 46 OR sdfhr.HCC2ICD10 = 46)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC46,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 47 OR sdfhr.HCC2ICD10 = 47)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC47,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 48 OR sdfhr.HCC2ICD10 = 48)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC48,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 51 OR sdfhr.HCC2ICD10 = 51)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC51,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 52 OR sdfhr.HCC2ICD10 = 52)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC52,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 54 OR sdfhr.HCC2ICD10 = 54)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC54,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 55 OR sdfhr.HCC2ICD10 = 55)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC55,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 57 OR sdfhr.HCC2ICD10 = 57)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC57,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 58 OR sdfhr.HCC2ICD10 = 58)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC58,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 70 OR sdfhr.HCC2ICD10 = 70)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC70,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 71 OR sdfhr.HCC2ICD10 = 71)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC71,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 72 OR sdfhr.HCC2ICD10 = 72)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC72,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 73 OR sdfhr.HCC2ICD10 = 73)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC73,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 74 OR sdfhr.HCC2ICD10 = 74)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC74,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 75 OR sdfhr.HCC2ICD10 = 75)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC75,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 76 OR sdfhr.HCC2ICD10 = 76)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC76,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 77 OR sdfhr.HCC2ICD10 = 77)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC77,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 78 OR sdfhr.HCC2ICD10 = 78)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC78,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 79 OR sdfhr.HCC2ICD10 = 79)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC79,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 80 OR sdfhr.HCC2ICD10 = 80)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC80,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 81 OR sdfhr.HCC2ICD10 = 81)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC81,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 82 OR sdfhr.HCC2ICD10 = 82)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC82,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 83 OR sdfhr.HCC2ICD10 = 83)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC83,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 84 OR sdfhr.HCC2ICD10 = 84)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC84,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 85 OR sdfhr.HCC2ICD10 = 85)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC85,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 86 OR sdfhr.HCC2ICD10 = 86)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC86,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 87 OR sdfhr.HCC2ICD10 = 87)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC87,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 88 OR sdfhr.HCC2ICD10 = 88)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC88,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 96 OR sdfhr.HCC2ICD10 = 96)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC96,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 99 OR sdfhr.HCC2ICD10 = 99)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC99,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 100 OR sdfhr.HCC2ICD10 = 100)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC100,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 103 OR sdfhr.HCC2ICD10 = 103)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC103,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 104 OR sdfhr.HCC2ICD10 = 104)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC104,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 106 OR sdfhr.HCC2ICD10 = 106)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC106,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 107 OR sdfhr.HCC2ICD10 = 107)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC107,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 108 OR sdfhr.HCC2ICD10 = 108)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC108,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 110 OR sdfhr.HCC2ICD10 = 110)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC110,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 111 OR sdfhr.HCC2ICD10 = 111)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC111,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 112 OR sdfhr.HCC2ICD10 = 112)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC112,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 114 OR sdfhr.HCC2ICD10 = 114)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC114,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 115 OR sdfhr.HCC2ICD10 = 115)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC115,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 122 OR sdfhr.HCC2ICD10 = 122)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC122,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 124 OR sdfhr.HCC2ICD10 = 124)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC124,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 134 OR sdfhr.HCC2ICD10 = 134)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC134,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 135 OR sdfhr.HCC2ICD10 = 135)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC135,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 136 OR sdfhr.HCC2ICD10 = 136)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC136,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 137 OR sdfhr.HCC2ICD10 = 137)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC137,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 138 OR sdfhr.HCC2ICD10 = 138)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC138,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 139 OR sdfhr.HCC2ICD10 = 139)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC139,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 140 OR sdfhr.HCC2ICD10 = 140)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC140,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 141 OR sdfhr.HCC2ICD10 = 141)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC141,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 157 OR sdfhr.HCC2ICD10 = 157)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC157,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 158 OR sdfhr.HCC2ICD10 = 158)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC158,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 159 OR sdfhr.HCC2ICD10 = 159)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC159,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 160 OR sdfhr.HCC2ICD10 = 160)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC160,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 161 OR sdfhr.HCC2ICD10 = 161)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC161,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 162 OR sdfhr.HCC2ICD10 = 162)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC162,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 166 OR sdfhr.HCC2ICD10 = 166)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC166,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 167 OR sdfhr.HCC2ICD10 = 167)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC167,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 169 OR sdfhr.HCC2ICD10 = 169)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC169,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 170 OR sdfhr.HCC2ICD10 = 170)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC170,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 173 OR sdfhr.HCC2ICD10 = 173)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC173,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 176 OR sdfhr.HCC2ICD10 = 176)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC176,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 186 OR sdfhr.HCC2ICD10 = 186)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC186,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 188 OR sdfhr.HCC2ICD10 = 188)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC188,
      COUNT(CASE WHEN (sdfhr.HCC2ICD9 = 189 OR sdfhr.HCC2ICD10 = 189)
        THEN sdfhr.GlobalMemberID
            ELSE NULL END) AS HCC189
    --into Junk..sample_HCCvars_for_HCC_risk
    FROM #temp_diagnosis_for_HCC_risk sdfhr
      JOIN #temp_diagnosis_for_HCC_risk sdgfhr
        ON sdfhr.GlobalMemberID = sdgfhr.GlobalMemberID
    GROUP BY sdfhr.GlobalMemberID
)
SELECT
  x.GlobalMemberID,
  CASE WHEN x.HCC1 > 0
    THEN 1
  ELSE 0 END HCC1,
  CASE WHEN x.HCC2 > 0
    THEN 1
  ELSE 0 END HCC2,
  CASE WHEN x.HCC6 > 0
    THEN 1
  ELSE 0 END HCC6,
  CASE WHEN x.HCC8 > 0
    THEN 1
  ELSE 0 END HCC8,
  CASE WHEN x.HCC9 > 0
    THEN 1
  ELSE 0 END HCC9,
  CASE WHEN x.HCC10 > 0
    THEN 1
  ELSE 0 END HCC10,
  CASE WHEN x.HCC11 > 0
    THEN 1
  ELSE 0 END HCC11,
  CASE WHEN x.HCC12 > 0
    THEN 1
  ELSE 0 END HCC12,
  CASE WHEN x.HCC17 > 0
    THEN 1
  ELSE 0 END HCC17,
  CASE WHEN x.HCC18 > 0
    THEN 1
  ELSE 0 END HCC18,
  CASE WHEN x.HCC19 > 0
    THEN 1
  ELSE 0 END HCC19,
  CASE WHEN x.HCC21 > 0
    THEN 1
  ELSE 0 END HCC21,
  CASE WHEN x.HCC22 > 0
    THEN 1
  ELSE 0 END HCC22,
  CASE WHEN x.HCC23 > 0
    THEN 1
  ELSE 0 END HCC23,
  CASE WHEN x.HCC27 > 0
    THEN 1
  ELSE 0 END HCC27,
  CASE WHEN x.HCC28 > 0
    THEN 1
  ELSE 0 END HCC28,
  CASE WHEN x.HCC29 > 0
    THEN 1
  ELSE 0 END HCC29,
  CASE WHEN x.HCC33 > 0
    THEN 1
  ELSE 0 END HCC33,
  CASE WHEN x.HCC34 > 0
    THEN 1
  ELSE 0 END HCC34,
  CASE WHEN x.HCC35 > 0
    THEN 1
  ELSE 0 END HCC35,
  CASE WHEN x.HCC39 > 0
    THEN 1
  ELSE 0 END HCC39,
  CASE WHEN x.HCC40 > 0
    THEN 1
  ELSE 0 END HCC40,
  CASE WHEN x.HCC46 > 0
    THEN 1
  ELSE 0 END HCC46,
  CASE WHEN x.HCC47 > 0
    THEN 1
  ELSE 0 END HCC47,
  CASE WHEN x.HCC51 > 0
    THEN 1
  ELSE 0 END HCC51,
  CASE WHEN x.HCC52 > 0
    THEN 1
  ELSE 0 END HCC52,
  CASE WHEN x.HCC48 > 0
    THEN 1
  ELSE 0 END HCC48,
  CASE WHEN x.HCC54 > 0
    THEN 1
  ELSE 0 END HCC54,
  CASE WHEN x.HCC55 > 0
    THEN 1
  ELSE 0 END HCC55,
  CASE WHEN x.HCC57 > 0
    THEN 1
  ELSE 0 END HCC57,
  CASE WHEN x.HCC58 > 0
    THEN 1
  ELSE 0 END HCC58,
  CASE WHEN x.HCC70 > 0
    THEN 1
  ELSE 0 END HCC70,
  CASE WHEN x.HCC71 > 0
    THEN 1
  ELSE 0 END HCC71,
  CASE WHEN x.HCC72 > 0
    THEN 1
  ELSE 0 END HCC72,
  CASE WHEN x.HCC73 > 0
    THEN 1
  ELSE 0 END HCC73,
  CASE WHEN x.HCC74 > 0
    THEN 1
  ELSE 0 END HCC74,
  CASE WHEN x.HCC75 > 0
    THEN 1
  ELSE 0 END HCC75,
  CASE WHEN x.HCC76 > 0
    THEN 1
  ELSE 0 END HCC76,
  CASE WHEN x.HCC77 > 0
    THEN 1
  ELSE 0 END HCC77,
  CASE WHEN x.HCC78 > 0
    THEN 1
  ELSE 0 END HCC78,
  CASE WHEN x.HCC79 > 0
    THEN 1
  ELSE 0 END HCC79,
  CASE WHEN x.HCC80 > 0
    THEN 1
  ELSE 0 END HCC80,
  CASE WHEN x.HCC81 > 0
    THEN 1
  ELSE 0 END HCC81,
  CASE WHEN x.HCC82 > 0
    THEN 1
  ELSE 0 END HCC82,
  CASE WHEN x.HCC83 > 0
    THEN 1
  ELSE 0 END HCC83,
  CASE WHEN x.HCC84 > 0
    THEN 1
  ELSE 0 END HCC84,
  CASE WHEN x.HCC85 > 0
    THEN 1
  ELSE 0 END HCC85,
  CASE WHEN x.HCC86 > 0
    THEN 1
  ELSE 0 END HCC86,
  CASE WHEN x.HCC87 > 0
    THEN 1
  ELSE 0 END HCC87,
  CASE WHEN x.HCC88 > 0
    THEN 1
  ELSE 0 END HCC88,
  CASE WHEN x.HCC96 > 0
    THEN 1
  ELSE 0 END HCC96,
  CASE WHEN x.HCC99 > 0
    THEN 1
  ELSE 0 END HCC99,
  CASE WHEN x.HCC100 > 0
    THEN 1
  ELSE 0 END HCC100,
  CASE WHEN x.HCC103 > 0
    THEN 1
  ELSE 0 END HCC103,
  CASE WHEN x.HCC104 > 0
    THEN 1
  ELSE 0 END HCC104,
  CASE WHEN x.HCC106 > 0
    THEN 1
  ELSE 0 END HCC106,
  CASE WHEN x.HCC107 > 0
    THEN 1
  ELSE 0 END HCC107,
  CASE WHEN x.HCC108 > 0
    THEN 1
  ELSE 0 END HCC108,
  CASE WHEN x.HCC110 > 0
    THEN 1
  ELSE 0 END HCC110,
  CASE WHEN x.HCC111 > 0
    THEN 1
  ELSE 0 END HCC111,
  CASE WHEN x.HCC112 > 0
    THEN 1
  ELSE 0 END HCC112,
  CASE WHEN x.HCC114 > 0
    THEN 1
  ELSE 0 END HCC114,
  CASE WHEN x.HCC115 > 0
    THEN 1
  ELSE 0 END HCC115,
  CASE WHEN x.HCC122 > 0
    THEN 1
  ELSE 0 END HCC122,
  CASE WHEN x.HCC124 > 0
    THEN 1
  ELSE 0 END HCC124,
  CASE WHEN x.HCC134 > 0
    THEN 1
  ELSE 0 END HCC134,
  CASE WHEN x.HCC135 > 0
    THEN 1
  ELSE 0 END HCC135,
  CASE WHEN x.HCC136 > 0
    THEN 1
  ELSE 0 END HCC136,
  CASE WHEN x.HCC137 > 0
    THEN 1
  ELSE 0 END HCC137,
  CASE WHEN x.HCC138 > 0
    THEN 1
  ELSE 0 END HCC138,
  CASE WHEN x.HCC139 > 0
    THEN 1
  ELSE 0 END HCC139,
  CASE WHEN x.HCC140 > 0
    THEN 1
  ELSE 0 END HCC140,
  CASE WHEN x.HCC141 > 0
    THEN 1
  ELSE 0 END HCC141,
  CASE WHEN x.HCC157 > 0
    THEN 1
  ELSE 0 END HCC157,
  CASE WHEN x.HCC158 > 0
    THEN 1
  ELSE 0 END HCC158,
  CASE WHEN x.HCC159 > 0
    THEN 1
  ELSE 0 END HCC159,
  CASE WHEN x.HCC160 > 0
    THEN 1
  ELSE 0 END HCC160,
  CASE WHEN x.HCC161 > 0
    THEN 1
  ELSE 0 END HCC161,
  CASE WHEN x.HCC162 > 0
    THEN 1
  ELSE 0 END HCC162,
  CASE WHEN x.HCC166 > 0
    THEN 1
  ELSE 0 END HCC166,
  CASE WHEN x.HCC167 > 0
    THEN 1
  ELSE 0 END HCC167,
  CASE WHEN x.HCC169 > 0
    THEN 1
  ELSE 0 END HCC169,
  CASE WHEN x.HCC170 > 0
    THEN 1
  ELSE 0 END HCC170,
  CASE WHEN x.HCC173 > 0
    THEN 1
  ELSE 0 END HCC173,
  CASE WHEN x.HCC176 > 0
    THEN 1
  ELSE 0 END HCC176,
  CASE WHEN x.HCC186 > 0
    THEN 1
  ELSE 0 END HCC186,
  CASE WHEN x.HCC188 > 0
    THEN 1
  ELSE 0 END HCC188,
  CASE WHEN x.HCC189 > 0
    THEN 1
  ELSE 0 END HCC189
INTO #temp_HCCvars_for_HCC_risk
FROM x

/*%*list of HCCs included in models;
 %LET HCCV22_list79 = %STR(
      HCC1    HCC2    HCC6    HCC8    HCC9    HCC10   HCC11   HCC12
      HCC17   HCC18   HCC19   HCC21   HCC22   HCC23   HCC27   HCC28
      HCC29   HCC33   HCC34   HCC35   HCC39   HCC40   HCC46   HCC47
      HCC48                   HCC54   HCC55   HCC57   HCC58   HCC70
      HCC71   HCC72   HCC73   HCC74   HCC75   HCC76   HCC77   HCC78
      HCC79   HCC80   HCC82   HCC83   HCC84   HCC85   HCC86   HCC87
      HCC88   HCC96   HCC99   HCC100  HCC103  HCC104  HCC106  HCC107
      HCC108  HCC110  HCC111  HCC112  HCC114  HCC115  HCC122  HCC124
      HCC134  HCC135  HCC136  HCC137
      HCC157  HCC158                  HCC161  HCC162  HCC166  HCC167
      HCC169  HCC170  HCC173  HCC176  HCC186  HCC188  HCC189
      );

 %*list of CCs that correspond to model HCCs;
 %LET CCV22_list79 = %STR(
      CC1     CC2     CC6     CC8     CC9     CC10    CC11    CC12
      CC17    CC18    CC19    CC21    CC22    CC23    CC27    CC28
      CC29    CC33    CC34    CC35    CC39    CC40    CC46    CC47
      CC48                    CC54    CC55    CC57    CC58    CC70
      CC71    CC72    CC73    CC74    CC75    CC76    CC77    CC78
      CC79    CC80    CC82    CC83    CC84    CC85    CC86    CC87
      CC88    CC96    CC99    CC100   CC103   CC104   CC106   CC107
      CC108   CC110   CC111   CC112   CC114   CC115   CC122   CC124
      CC134   CC135   CC136   CC137
      CC157   CC158                   CC161   CC162   CC166   CC167
      CC169   CC170   CC173   CC176   CC186   CC188   CC189
      );*/

-- get interaction variables for HCC,disability, age etc.

SELECT
  b.*,
  CASE WHEN e.Sex = 'F' AND e.MCAID = 1 AND e.DISABL = 0
    THEN 1
  ELSE 0 END          AS MCAID_Female_Aged,
  CASE WHEN e.Sex = 'F' AND e.MCAID = 1 AND e.DISABL = 1
    THEN 1
  ELSE 0 END          AS MCAID_Female_Disabled,
  CASE WHEN e.Sex = 'M' AND e.MCAID = 1 AND e.DISABL = 0
    THEN 1
  ELSE 0 END          AS MCAID_Male_Aged,
  CASE WHEN e.Sex = 'M' AND e.MCAID = 1 AND e.DISABL = 1
    THEN 1
  ELSE 0 END          AS MCAID_Male_Disabled,
  CASE WHEN e.Sex = 'F' AND e.ORIGDS = 1
    THEN 1
  ELSE 0 END          AS OriginallyDisabled_Female,
  CASE WHEN e.Sex = 'M' AND e.ORIGDS = 1
    THEN 1
  ELSE 0 END          AS OriginallyDisabled_Male,
  CASE WHEN e.Age >= 65 AND e.OREC = 1 AND e.NEW_ENROLLEE = 1
    THEN 1
  ELSE 0 END          AS NE_ORIGDS,
  CASE WHEN (e.MCAID <> 1 AND NOT (e.Age >= 65 AND e.OREC = 1) AND e.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END          AS NMCAID_NORIGDS,
  CASE WHEN (e.MCAID = 1 AND NOT (e.Age >= 65 AND e.OREC = 1) AND e.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END          AS MCAID_NORIGDS,
  CASE WHEN (e.MCAID = 1 AND (e.Age >= 65 AND e.OREC = 1) AND e.NEW_ENROLLEE = 1)
    THEN 1
  ELSE 0 END          AS MCAID_ORIGDS,
  CASE WHEN (b.HCC8 = 1 OR b.HCC9 = 1 OR b.HCC10 = 1 OR b.HCC11 = 1 OR b.HCC12 = 1)
    THEN 1
  ELSE 0 END          AS CANCER,
  CASE WHEN (b.HCC18 = 1 OR b.HCC19 = 1 OR b.HCC17 = 1)
    THEN 1
  ELSE 0 END          AS DIABETES,
  CASE WHEN (b.HCC47 = 1)
    THEN 1
  ELSE 0 END          AS IMMUNE,
  CASE WHEN (b.HCC82 = 1 OR b.HCC83 = 1 OR b.HCC84 = 1)
    THEN 1
  ELSE 0 END          AS CARD_RESP_FAIL,
  CASE WHEN (b.HCC85 = 1)
    THEN 1
  ELSE 0 END          AS CHF,
  CASE WHEN (b.HCC110 = 1 OR b.HCC111 = 1)
    THEN 1
  ELSE 0 END          AS COPD,
  CASE WHEN (b.HCC134 = 1 OR b.HCC135 = 1 OR b.HCC136 = 1 OR b.HCC137 = 1)
    THEN 1
  ELSE 0 END          AS RENAL,
  CASE WHEN (b.HCC176 = 1)
    THEN 1
  ELSE 0 END          AS COMPL,
  CASE WHEN (b.HCC2 = 1)
    THEN 1
  ELSE 0 END          AS SEPSIS,
  CASE WHEN (b.HCC157 = 1 OR b.HCC158 = 1)
    THEN 1
  ELSE 0 END          AS PRESSURE_ULCER,
  e.DISABL * b.HCC6   AS DISABLED_HCC6,
  --   = DISABL*HCC6;   %*Opportunistic Infections;
  e.DISABL * b.HCC34  AS DISABLED_HCC34,
  --   = DISABL*HCC34;  %*Chronic Pancreatitis;
  e.DISABL * b.HCC46  AS DISABLED_HCC46,
  --   = DISABL*HCC46;  %*Severe Hematol Disorders;
  e.DISABL * b.HCC54  AS DISABLED_HCC54,
  --   = DISABL*HCC54;  %*Drug/Alcohol Psychosis;
  e.DISABL * b.HCC55  AS DISABLED_HCC55,
  --   = DISABL*HCC55;  %*Drug/Alcohol Dependence;
  e.DISABL * b.HCC10  AS DISABLED_HCC110,
  --   = DISABL*HCC110; %*Cystic Fibrosis;
  e.DISABL * b.HCC176 AS DISABLED_HCC176,
  --   = DISABL*HCC176; %* added 7/2009;
  e.DISABL * b.HCC85  AS DISABLED_HCC85,
  --          = DISABL*(HCC85);
  e.DISABL * b.HCC161 AS DISABLED_HCC161,
  --        = DISABL*(HCC161);
  e.DISABL * b.HCC39  AS DISABLED_HCC39,
  --       = DISABL*(HCC39);
  e.DISABL * b.HCC77  AS DISABLED_HCC77
--       = DISABL*(HCC77);
INTO #temp_HCCvars
FROM (SELECT *
      FROM #temp_HCCvars_for_HCC_risk) b
  JOIN (SELECT *
        FROM #temp_cohort1_for_HCC_risk) e
    ON b.GlobalMemberID = e.GlobalMemberID

SELECT
  x.*,
  x.SEPSIS * x.CARD_RESP_FAIL AS SEPSIS_CARD_RESP_FAIL,
  -- =  SEPSIS*CARD_RESP_FAIL;
  x.CANCER * x.IMMUNE         AS CANCER_IMMUNE,
  --        =  CANCER*IMMUNE;
  x.DIABETES * x.CHF          AS DIABETES_CHF,
  --          =  DIABETES*CHF ;
  x.CHF * x.COPD              AS CHF_COPD,
  --             =  CHF*COPD     ;
  x.CHF * x.RENAL             AS CHF_RENAL,
  --            =  CHF*RENAL    ;
  x.COPD * x.CARD_RESP_FAIL   AS COPD_CARD_RESP_FAIL,
  --  =  COPD*CARD_RESP_FAIL  ;
  x.SEPSIS * x.PRESSURE_ULCER AS SEPSIS_PRESSURE_ULCER,
  -- = SEPSIS*PRESSURE_ULCER;
  x.SEPSIS * x.HCC188         AS SEPSIS_ARTIF_OPENINGS,
  -- = SEPSIS*(HCC188);
  x.HCC188 * x.PRESSURE_ULCER AS ART_OPENINGS_PRESSURE_ULCER,
  -- = (HCC188)*PRESSURE_ULCER;
  --x.DIABETES*x.CHF as DIABETES_CHF, -- = DIABETES*CHF;
  x.COPD * x.HCC114           AS COPD_ASP_SPEC_BACT_PNEUM,
  -- = COPD*(HCC114);
  x.HCC114 * x.PRESSURE_ULCER AS ASP_SPEC_BACT_PNEUM_PRES_ULC,
  --= (HCC114)*PRESSURE_ULCER;
  x.HCC114 * x.SEPSIS         AS SEPSIS_ASP_SPEC_BACT_PNEUM,
  --= SEPSIS*(HCC114);
  x.HCC57 * x.COPD            AS SCHIZOPHRENIA_COPD,
  -- = (HCC57)*COPD;
  x.HCC57 * x.CHF             AS SCHIZOPHRENIA_CHF,
  --= (HCC57)*CHF;
  x.HCC57 * x.HCC79           AS SCHIZOPHRENIA_SEIZURES -- = (HCC57)*(HCC79);

INTO #temp_HCCintvars_for_HCC_risk
FROM #temp_HCCvars x

/* %*interactions;

           %************************
            * interaction variables
            *************************;

            %*interactions ;
            SEPSIS_CARD_RESP_FAIL =  SEPSIS*CARD_RESP_FAIL;
            CANCER_IMMUNE         =  CANCER*IMMUNE;
            DIABETES_CHF          =  DIABETES*CHF ;
            CHF_COPD              =  CHF*COPD     ;
            CHF_RENAL             =  CHF*RENAL    ;
            COPD_CARD_RESP_FAIL   =  COPD*CARD_RESP_FAIL  ;
            %*institutional model;
            PRESSURE_ULCER = MAX(HCC157, HCC158); /*10/19/2012*/;
            SEPSIS_PRESSURE_ULCER = SEPSIS*PRESSURE_ULCER;
            SEPSIS_ARTIF_OPENINGS = SEPSIS*(HCC188);
            ART_OPENINGS_PRESSURE_ULCER = (HCC188)*PRESSURE_ULCER;
            DIABETES_CHF = DIABETES*CHF;
            COPD_ASP_SPEC_BACT_PNEUM = COPD*(HCC114);
            ASP_SPEC_BACT_PNEUM_PRES_ULC = (HCC114)*PRESSURE_ULCER;
            SEPSIS_ASP_SPEC_BACT_PNEUM = SEPSIS*(HCC114);
            SCHIZOPHRENIA_COPD = (HCC57)*COPD;
            SCHIZOPHRENIA_CHF= (HCC57)*CHF;
            SCHIZOPHRENIA_SEIZURES = (HCC57)*(HCC79);

            DISABLED_HCC85          = DISABL*(HCC85);
            DISABLED_PRESSURE_ULCER = DISABL*PRESSURE_ULCER;
            DISABLED_HCC161         = DISABL*(HCC161);
            DISABLED_HCC39          = DISABL*(HCC39);
            DISABLED_HCC77          = DISABL*(HCC77);

             MCAID_Female_Aged     = MCAID*(SEX='2')*(1 - DISABL);
           MCAID_Female_Disabled = MCAID*(SEX='2')*DISABL;
           MCAID_Male_Aged       = MCAID*(SEX='1')*(1 - DISABL);
           MCAID_Male_Disabled   = MCAID*(SEX='1')*DISABL;
           OriginallyDisabled_Female= ORIGDS*(SEX='2');
           OriginallyDisabled_Male  = ORIGDS*(SEX='1');

           %* NE interactions;
           NE_ORIGDS       = (AGEF>=65)*(OREC='1');
           NMCAID_NORIGDIS = (NEMCAID <=0 and NE_ORIGDS <=0);
           MCAID_NORIGDIS  = (NEMCAID > 0 and NE_ORIGDS <=0);
           NMCAID_ORIGDIS  = (NEMCAID <=0 and NE_ORIGDS > 0);
           MCAID_ORIGDIS   = (NEMCAID > 0 and NE_ORIGDS > 0);

           %*community model diagnostic categories;
            CANCER         = MAX(HCC8, HCC9, HCC10, HCC11, HCC12);
            DIABETES       = MAX(HCC17, HCC18, HCC19);
            IMMUNE         = HCC47;
            CARD_RESP_FAIL = MAX(HCC82, HCC83, HCC84);
            CHF            = HCC85;
            COPD           = MAX(HCC110, HCC111);
            RENAL          = MAX(HCC134, HCC135, HCC136, HCC137);
            COMPL          = HCC176;
            SEPSIS         = HCC2;

            %*interactions with disabled ;
            DISABLED_HCC6   = DISABL*HCC6;   %*Opportunistic Infections;
            DISABLED_HCC34  = DISABL*HCC34;  %*Chronic Pancreatitis;
            DISABLED_HCC46  = DISABL*HCC46;  %*Severe Hematol Disorders;
            DISABLED_HCC54  = DISABL*HCC54;  %*Drug/Alcohol Psychosis;
            DISABLED_HCC55  = DISABL*HCC55;  %*Drug/Alcohol Dependence;
            DISABLED_HCC110 = DISABL*HCC110; %*Cystic Fibrosis;
            DISABLED_HCC176 = DISABL*HCC176; %* added 7/2009;

*/
-- Create HCC scores for each patient

SELECT
  a.GlobalMemberID                                           AS GlobalMemberID,
  hcc.HCCCoefYear                                            AS ModelYear,
  (hcc.CE_F0_34 * b.F0_34 + hcc.CE_F35_44 * b.F35_44 + hcc.CE_F45_54 * b.F45_54 + hcc.CE_F55_59 * b.F55_59 +
   hcc.CE_F60_64 * b.F60_64 +
   hcc.CE_F65_69 * b.F65_69 + hcc.CE_F70_74 * b.F70_74 + hcc.CE_F75_79 * b.F75_79 + hcc.CE_F80_84 * b.F80_84 +
   hcc.CE_F85_89 * b.F85_89 +
   hcc.CE_F90_94 * b.F90_94 + hcc.CE_F95_GT * b.F95_GT) -- Demo for Females
  + (hcc.CE_M0_34 * b.M0_34 + hcc.CE_M35_44 * b.M35_44 + hcc.CE_M45_54 * b.M45_54 + hcc.CE_M55_59 * b.M55_59 +
     hcc.CE_M60_64 * b.M60_64 +
     hcc.CE_M65_69 * b.M65_69 + hcc.CE_M70_74 * b.M70_74 + hcc.CE_M75_79 * b.M75_79 + hcc.CE_M80_84 * b.M80_84 +
     hcc.CE_M85_89 * b.M85_89 +
     hcc.CE_M90_94 * b.M90_94 + hcc.CE_M95_GT * b.M95_GT) -- Demo for Males
  + (hcc.CE_HCC1 * c.HCC1 + hcc.CE_HCC2 * c.HCC2 + hcc.CE_HCC6 * c.HCC6 + hcc.CE_HCC8 * c.HCC8 + hcc.CE_HCC9 * c.HCC9 +
     hcc.CE_HCC10 * c.HCC10 +
     hcc.CE_HCC11 * c.HCC11 + hcc.CE_HCC12 * c.HCC12 + hcc.CE_HCC17 * c.HCC17 + hcc.CE_HCC18 * c.HCC18 + hcc.CE_HCC18 +
     c.HCC19 + hcc.CE_HCC21 * c.HCC21 +
     hcc.CE_HCC22 * c.HCC22 + hcc.CE_HCC23 * c.HCC23 + hcc.CE_HCC27 * c.HCC27 + hcc.CE_HCC28 * c.HCC28 +
     hcc.CE_HCC29 * c.HCC29 + hcc.CE_HCC33 * c.HCC33 +
     hcc.CE_HCC34 * c.HCC34 + hcc.CE_HCC35 * c.HCC35 + hcc.CE_HCC39 * c.HCC39 + hcc.CE_HCC40 * c.HCC40 +
     hcc.CE_HCC46 * c.HCC46 + hcc.CE_HCC47 * c.HCC47 +
     hcc.CE_HCC48 * c.HCC48 + hcc.CE_HCC51 * c.HCC51 + hcc.CE_HCC52 * c.HCC52 + hcc.CE_HCC54 * c.HCC54 +
     hcc.CE_HCC55 * c.HCC55 + hcc.CE_HCC57 * c.HCC57 +
     hcc.CE_HCC58 * c.HCC58 + hcc.CE_HCC70 * c.HCC70 + hcc.CE_HCC71 * c.HCC70 + hcc.CE_HCC72 * c.HCC72 +
     hcc.CE_HCC73 * c.HCC73 + hcc.CE_HCC74 * c.HCC74 +
     hcc.CE_HCC75 * c.HCC75 + hcc.CE_HCC76 * c.HCC76 + hcc.CE_HCC76 * c.HCC76 + hcc.CE_HCC77 * c.HCC77 +
     hcc.CE_HCC78 * c.HCC79 + hcc.CE_HCC80 * c.HCC80 +
     hcc.CE_HCC82 * c.HCC82 + hcc.CE_HCC83 * c.HCC83 + hcc.CE_HCC84 * c.HCC84 + hcc.CE_HCC85 * c.HCC85 +
     hcc.CE_HCC86 * c.HCC86 + hcc.CE_HCC87 * c.HCC87 +
     hcc.CE_HCC88 * c.HCC88 + hcc.CE_HCC96 * c.HCC96 + hcc.CE_HCC99 * c.HCC99 + hcc.CE_HCC100 * c.HCC100 +
     hcc.CE_HCC103 * c.HCC103 + hcc.CE_HCC104 * c.HCC104 +
     hcc.CE_HCC106 * c.HCC106 + hcc.CE_HCC107 * c.HCC107 + hcc.CE_HCC108 * c.HCC108 + hcc.CE_HCC110 * c.HCC110 +
     hcc.CE_HCC111 * c.HCC111 + hcc.CE_HCC112 * c.HCC112 +
     hcc.CE_HCC114 * c.HCC114 + hcc.CE_HCC115 * c.HCC115 + hcc.CE_HCC122 * c.HCC122 + hcc.CE_HCC124 * c.HCC124 +
     hcc.CE_HCC134 * c.HCC134 + hcc.CE_HCC135 * c.HCC135 +
     hcc.CE_HCC136 * c.HCC136 + hcc.CE_HCC137 * c.HCC137 + hcc.CE_HCC137 * c.HCC137 + hcc.CE_HCC138 * c.HCC138 +
     hcc.CE_HCC139 * c.HCC139 + hcc.CE_HCC140 * c.HCC140 +
     hcc.CE_HCC141 * c.HCC141 + hcc.CE_HCC157 * c.HCC157 + hcc.CE_HCC158 * c.HCC158 + hcc.CE_HCC159 * c.HCC159 +
     hcc.CE_HCC160 * c.HCC160 + hcc.CE_HCC161 * c.HCC161 +
     hcc.CE_HCC162 * c.HCC162 + hcc.CE_HCC166 * c.HCC166 + hcc.CE_HCC167 * c.HCC167 + hcc.CE_HCC169 * c.HCC169 +
     hcc.CE_HCC170 * c.HCC170 + hcc.CE_HCC173 * c.HCC173 +
     hcc.CE_HCC176 * c.HCC176 + hcc.CE_HCC186 * c.HCC186 + hcc.CE_HCC188 * c.HCC188 + hcc.CE_HCC189 * c.HCC189)
  -- HCC vars
  + (hcc.CE_MCAID_Female_Aged * d.MCAID_Female_Aged + hcc.CE_MCAID_Female_Disabled * d.MCAID_Female_Disabled +
     hcc.CE_MCAID_Male_Aged * d.MCAID_Male_Aged + hcc.CE_MCAID_Male_Disabled * d.MCAID_Male_Disabled +
     -- HCC interactions vars
     hcc.CE_OriginallyDisabled_Female * d.OriginallyDisabled_Female +
     hcc.CE_OriginallyDisabled_Male * d.OriginallyDisabled_Male + hcc.CE_CANCER_IMMUNE * d.CANCER_IMMUNE +
     hcc.CE_COPD_CARD_RESP_FAIL * d.COPD_CARD_RESP_FAIL +
     hcc.CE_CHF_COPD * d.CHF_COPD + hcc.CE_CHF_RENAL * d.CHF_RENAL + hcc.CE_DIABETES_CHF * d.DIABETES_CHF +
     hcc.CE_DISABLED_HCC6 * d.DISABLED_HCC6 + hcc.CE_DISABLED_HCC34 * d.DISABLED_HCC34 +
     hcc.CE_DISABLED_HCC46 * d.DISABLED_HCC46 +
     hcc.CE_DISABLED_HCC54 * d.DISABLED_HCC54 + hcc.CE_DISABLED_HCC55 * d.DISABLED_HCC55 +
     hcc.CE_DISABLED_HCC110 * d.DISABLED_HCC110 + hcc.CE_DISABLED_HCC176 * d.DISABLED_HCC176 +
     hcc.CE_SEPSIS_CARD_RESP_FAIL * d.SEPSIS_CARD_RESP_FAIL) AS HCC_RISK_SCORE_CE,
  (hcc.INS_F0_34 * b.F0_34 + hcc.INS_F35_44 * b.F35_44 + hcc.INS_F45_54 * b.F45_54 + hcc.INS_F55_59 * b.F55_59 +
   hcc.INS_F60_64 * b.F60_64 +
   hcc.INS_F65_69 * b.F65_69 + hcc.INS_F70_74 * b.F70_74 + hcc.INS_F75_79 * b.F75_79 + hcc.INS_F80_84 * b.F80_84 +
   hcc.INS_F85_89 * b.F85_89 +
   hcc.INS_F90_94 * b.F90_94 + hcc.INS_F95_GT * b.F95_GT) -- Demo for Females
  + (hcc.INS_M0_34 * b.M0_34 + hcc.INS_M35_44 * b.M35_44 + hcc.INS_M45_54 * b.M45_54 + hcc.INS_M55_59 * b.M55_59 +
     hcc.INS_M60_64 * b.M60_64 +
     hcc.INS_M65_69 * b.M65_69 + hcc.INS_M70_74 * b.M70_74 + hcc.INS_M75_79 * b.M75_79 + hcc.INS_M80_84 * b.M80_84 +
     hcc.INS_M85_89 * b.M85_89 +
     hcc.INS_M90_94 * b.M90_94 + hcc.INS_M95_GT * b.M95_GT) -- Demo for Males
  + (hcc.INS_HCC1 * c.HCC1 + hcc.INS_HCC2 * c.HCC2 + hcc.INS_HCC6 * c.HCC6 + hcc.INS_HCC8 * c.HCC8 +
     hcc.INS_HCC9 * c.HCC9 + hcc.INS_HCC10 * c.HCC10 +
     hcc.INS_HCC11 * c.HCC11 + hcc.INS_HCC12 * c.HCC12 + hcc.INS_HCC17 * c.HCC17 + hcc.INS_HCC18 * c.HCC18 +
     hcc.INS_HCC18 + c.HCC19 + hcc.INS_HCC21 * c.HCC21 +
     hcc.INS_HCC22 * c.HCC22 + hcc.INS_HCC23 * c.HCC23 + hcc.INS_HCC27 * c.HCC27 + hcc.INS_HCC28 * c.HCC28 +
     hcc.INS_HCC29 * c.HCC29 + hcc.INS_HCC33 * c.HCC33 +
     hcc.INS_HCC34 * c.HCC34 + hcc.INS_HCC35 * c.HCC35 + hcc.INS_HCC39 * c.HCC39 + hcc.INS_HCC40 * c.HCC40 +
     hcc.INS_HCC46 * c.HCC46 + hcc.INS_HCC47 * c.HCC47 +
     hcc.INS_HCC48 * c.HCC48 + hcc.INS_HCC51 * c.HCC51 + hcc.INS_HCC52 * c.HCC52 + hcc.INS_HCC54 * c.HCC54 +
     hcc.INS_HCC55 * c.HCC55 + hcc.INS_HCC57 * c.HCC57 +
     hcc.INS_HCC58 * c.HCC58 + hcc.INS_HCC70 * c.HCC70 + hcc.INS_HCC71 * c.HCC70 + hcc.INS_HCC72 * c.HCC72 +
     hcc.INS_HCC73 * c.HCC73 + hcc.INS_HCC74 * c.HCC74 +
     hcc.INS_HCC75 * c.HCC75 + hcc.INS_HCC76 * c.HCC76 + hcc.INS_HCC76 * c.HCC76 + hcc.INS_HCC77 * c.HCC77 +
     hcc.INS_HCC78 * c.HCC79 + hcc.INS_HCC80 * c.HCC80 +
     hcc.INS_HCC82 * c.HCC82 + hcc.INS_HCC83 * c.HCC83 + hcc.INS_HCC84 * c.HCC84 + hcc.INS_HCC85 * c.HCC85 +
     hcc.INS_HCC86 * c.HCC86 + hcc.INS_HCC87 * c.HCC87 +
     hcc.INS_HCC88 * c.HCC88 + hcc.INS_HCC96 * c.HCC96 + hcc.INS_HCC99 * c.HCC99 + hcc.INS_HCC100 * c.HCC100 +
     hcc.INS_HCC103 * c.HCC103 + hcc.INS_HCC104 * c.HCC104 +
     hcc.INS_HCC106 * c.HCC106 + hcc.INS_HCC107 * c.HCC107 + hcc.INS_HCC108 * c.HCC108 + hcc.INS_HCC110 * c.HCC110 +
     hcc.INS_HCC111 * c.HCC111 + hcc.INS_HCC112 * c.HCC112 +
     hcc.INS_HCC114 * c.HCC114 + hcc.INS_HCC115 * c.HCC115 + hcc.INS_HCC122 * c.HCC122 + hcc.INS_HCC124 * c.HCC124 +
     hcc.INS_HCC134 * c.HCC134 + hcc.INS_HCC135 * c.HCC135 +
     hcc.INS_HCC136 * c.HCC136 + hcc.INS_HCC137 * c.HCC137 + hcc.INS_HCC137 * c.HCC137 + hcc.INS_HCC138 * c.HCC138 +
     hcc.INS_HCC139 * c.HCC139 + hcc.INS_HCC140 * c.HCC140 +
     hcc.INS_HCC141 * c.HCC141 + hcc.INS_HCC157 * c.HCC157 + hcc.INS_HCC158 * c.HCC158 + hcc.INS_HCC159 * c.HCC159 +
     hcc.INS_HCC160 * c.HCC160 + hcc.INS_HCC161 * c.HCC161 +
     hcc.INS_HCC162 * c.HCC162 + hcc.INS_HCC166 * c.HCC166 + hcc.INS_HCC167 * c.HCC167 + hcc.INS_HCC169 * c.HCC169 +
     hcc.INS_HCC170 * c.HCC170 + hcc.INS_HCC173 * c.HCC173 +
     hcc.INS_HCC176 * c.HCC176 + hcc.INS_HCC186 * c.HCC186 + hcc.INS_HCC188 * c.HCC188 + hcc.INS_HCC189 * c.HCC189)
  --HCC vars
  + (hcc.INS_ART_OPENINGS_PRESSURE_ULCER * d.ART_OPENINGS_PRESSURE_ULCER +
     hcc.INS_ASP_SPEC_BACT_PNEUM_PRES_ULC * d.ASP_SPEC_BACT_PNEUM_PRES_ULC + hcc.INS_CHF_COPD * d.CHF_COPD +
     hcc.INS_COPD_ASP_SPEC_BACT_PNEUM * d.COPD_ASP_SPEC_BACT_PNEUM + hcc.INS_COPD_CARD_RESP_FAIL * d.COPD_CARD_RESP_FAIL
     + hcc.INS_DIABETES_CHF * d.DIABETES_CHF + hcc.INS_DISABLED_HCC6 * d.DISABLED_HCC6 +
     hcc.INS_DISABLED_HCC39 * d.DISABLED_HCC39 + hcc.INS_DISABLED_HCC77 * d.DISABLED_HCC77 +
     hcc.INS_DISABLED_HCC85 * d.DISABLED_HCC85 + hcc.INS_DISABLED_HCC161 * d.DISABLED_HCC161 +
     hcc.INS_SCHIZOPHRENIA_CHF * d.SCHIZOPHRENIA_CHF +
     hcc.INS_SCHIZOPHRENIA_COPD * d.SCHIZOPHRENIA_COPD + hcc.INS_SCHIZOPHRENIA_SEIZURES * d.SCHIZOPHRENIA_SEIZURES +
     hcc.INS_SEPSIS_ARTIF_OPENINGS * d.SEPSIS_ARTIF_OPENINGS +
     hcc.INS_SEPSIS_ASP_SPEC_BACT_PNEUM * d.SEPSIS_ASP_SPEC_BACT_PNEUM +
     hcc.INS_SEPSIS_PRESSURE_ULCER * d.SEPSIS_PRESSURE_ULCER +
     hcc.INS_ORIGDS * a.ORIGDS)-- HCC interaction variables+ add medicaid when available
                                                             AS HCC_RISK_SCORE_INS,
  (hcc.NE_NEF0_34 * b.NEF0_34 + hcc.NE_NEF35_44 * b.NEF35_44 + hcc.NE_NEF45_54 * b.NEF45_54 +
   hcc.NE_NEF55_59 * b.NEF55_59 + hcc.NE_NEF60_64 * b.NEF60_64 + hcc.NE_NEF65 * b.NEF65 + hcc.NE_NEF66 * b.NEF66 +
   hcc.NE_NEF67 * b.NEF67 + hcc.NE_NEF68 * b.NEF68 + hcc.NE_NEF69 * b.NEF69 + hcc.NE_NEF70_74 * b.NEF70_74 +
   hcc.NE_NEF75_79 * b.NEF75_79 + hcc.NE_NEF80_84 * b.NEF80_84 + hcc.NE_NEF85_89 * b.NEF85_89 +
   hcc.NE_NEF90_94 * b.NEF90_94 + hcc.NE_NEF95_GT * b.NEF95_GT) --  Demo vars Female
  + (hcc.NE_NEM0_34 * b.NEM0_34 + hcc.NE_NEM35_44 * b.NEM35_44 + hcc.NE_NEM45_54 * b.NEM45_54 +
     hcc.NE_NEM55_59 * b.NEM55_59 + hcc.NE_NEM60_64 * b.NEM60_64 + hcc.NE_NEM65 * b.NEM65 + hcc.NE_NEM66 * b.NEM66 +
     hcc.NE_NEM67 * b.NEM67 + hcc.NE_NEM68 * b.NEM68 + hcc.NE_NEM69 * b.NEM69 + hcc.NE_NEM70_74 * b.NEM70_74 +
     hcc.NE_NEM75_79 * b.NEM75_79 + hcc.NE_NEM80_84 * b.NEM80_84 + hcc.NE_NEM85_89 * b.NEM85_89 +
     hcc.NE_NEM90_94 * b.NEM90_94 + hcc.NE_NEM95_GT * b.NEM95_GT) -- Demo vars Male
  + (hcc.NE_ORIGDIS_FEMALE65 * a.ORIGDS * b.NEF65 +
     hcc.NE_ORIGDIS_FEMALE66_69 * a.ORIGDS * (b.NEF66 + b.NEF67 + b.NEF68 + b.NEF69) +
     hcc.NE_ORIGDIS_FEMALE70_74 * a.ORIGDS * b.NEF70_74 +
     hcc.NE_ORIGDIS_FEMALE75_GT * a.ORIGDS * (b.NEF75_79 + b.NEF80_84 + b.NEF85_89 + b.NEF90_94 + b.NEF95_GT))
  -- special status vars female
  + (hcc.NE_ORIGDIS_MALE65 * a.ORIGDS * b.NEM65 +
     hcc.NE_ORIGDIS_MALE66_69 * a.ORIGDS * (b.NEM66 + b.NEM67 + b.NEM68 + b.NEM69) +
     hcc.NE_ORIGDIS_MALE70_74 * a.ORIGDS * b.NEM70_74 +
     hcc.NE_ORIGDIS_MALE75_GT * a.ORIGDS * (b.NEM75_79 + b.NEM80_84 + b.NEM85_89 + b.NEM90_94 + b.NEM95_GT))
  -- special status vars MALE
  + (hcc.NE_MCAID_FEMALE0_64 * (b.NEF0_34 + b.NEF35_44 + b.NEF45_54 + b.NEF55_59 + b.NEF60_64) +
     hcc.NE_MCAID_FEMALE65 * b.NEF65 + hcc.NE_MCAID_FEMALE66_69 * (b.NEF66 + b.NEF67 + b.NEF68 + b.NEF69) +
     hcc.NE_MCAID_FEMALE70_74 * b.NEF70_74 +
     hcc.NE_MCAID_FEMALE75_GT * (b.NEF75_79 + b.NEF80_84 + b.NEF85_89 + b.NEF90_94 + b.NEF95_GT)) * a.MCAID
  --  Medicaid variables female
  + (hcc.NE_MCAID_MALE0_64 * (b.NEM0_34 + b.NEM35_44 + b.NEM45_54 + b.NEM55_59 + b.NEM60_64) +
     hcc.NE_MCAID_MALE65 * b.NEM65 + hcc.NE_MCAID_MALE66_69 * (b.NEM66 + b.NEM67 + b.NEM68 + b.NEM69) +
     hcc.NE_MCAID_MALE70_74 * b.NEM70_74 +
     hcc.NE_MCAID_MALE75_GT * (b.NEM75_79 + b.NEM80_84 + b.NEM85_89 + b.NEM90_94 + b.NEM95_GT)) *
    a.MCAID --  Medicaid variables MALE
                                                             AS HCC_RISK_SCORE_NE
into #temp_HCCRiskScores
FROM #temp_cohort1_for_HCC_risk a
  JOIN #temp_demo_for_HCC_risk b ON a.GlobalMemberID = b.GlobalMemberID
  JOIN #temp_HCCvars_for_HCC_risk c ON b.GlobalMemberID = c.GlobalMemberID
  JOIN #temp_HCCintvars_for_HCC_risk d ON c.GlobalMemberID = d.GlobalMemberID
  CROSS JOIN ref..HCCCoef hcc
WHERE hcc.HCCCoefYear = @HCCCoefYear


----------------- DONE ---------------------------------------------------------------------------------------		
        
		DROP TABLE #temp_cohort_for_HCC_risk; 
        DROP TABLE #temp_cohort1_for_HCC_risk;        
        DROP TABLE #temp_demo_for_HCC_risk;        
        DROP TABLE #temp_HCCvars_for_HCC_risk;             
        DROP TABLE #temp_HCCintvars_for_HCC_risk;        
        DROP TABLE #temp_HCCvars; 
		DROP TABLE #temp_diagnosis_for_HCC_risk;        


        INSERT  INTO ODS..HCCRiskScores
                (
                  GlobalMemberID ,
                  FeatureBatchID,
                  ModelYear ,
                  PeriodStart ,
                  PeriodEnd ,
                  HealthPlanID ,
				  HCC_RISK_SCORE_CE,
				  HCC_RISK_SCORE_INS,
				  HCC_RISK_SCORE_NE,
                  RecordInsertedDatetime ,
                  RecordInsertedBy
                )
                SELECT  v.GlobalMemberID ,
                        @HCCBatchID AS FeatureBatchID ,
                        v.ModelYear ,
                        @FromDate ,
                        @ToDate ,
                        @HealthPlanID ,
                        v.HCC_RISK_SCORE_CE,
						v.HCC_RISK_SCORE_INS,
						v.HCC_RISK_SCORE_NE,
                        GETDATE() ,
                        SYSTEM_USER
                FROM    #temp_HCCRiskScores v;

		

    END;
	
