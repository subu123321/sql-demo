/****** Object:  StoredProcedure [dbo].[PrintBuildingPermit]    Script Date: 22/11/2024 12:36:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Stored Procedure

CREATE PROCEDURE [dbo].[PrintBuildingPermit_Test]-- 1165
	/*@buildingPermitCode varchar(50)*/ @applicationId INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @EServiceID INT;
        SET @EServiceID = ( SELECT  EServiceID
                            FROM    Application
                            WHERE   ApplicationID = @applicationId
                          );

						  declare @EserviceIDOld int
		declare @ApplicationCode varchar(50)
		set @EserviceIDOld = @EServiceID;
		select @ApplicationCode = ApplicationCode from Application where ApplicationID = @applicationId



		IF @EServiceID=26 OR @EServiceID=27
		BEGIN
			IF @EServiceID=26 
				SELECT @applicationId=APPLICATIONID FROM ISSUANCEOFNEWBUILDINGPERMIT WHERE BUILDINGPERMITID IN(SELECT BUILDINGPERMITID FROM CHANGECONSULTANT WHERE APPLICATIONID=@applicationId);
			IF @EServiceID=27
				SELECT @applicationId=APPLICATIONID FROM ISSUANCEOFNEWBUILDINGPERMIT WHERE BUILDINGPERMITID IN(SELECT BUILDINGPERMITID FROM ChangeContractor WHERE APPLICATIONID=@applicationId);
			SELECT @EServiceID=EServiceID FROM APPLICATION WHERE APPLICATIONID=@applicationId;
		END

        IF @EServiceID = 1
            OR @EServiceID = 3
            OR @EServiceID = 5
            BEGIN
                SELECT TOP 1
                        aps.ApplicationStateNameEn ,
                        a.ApplicationID ,
                        @ApplicationCode ApplicationCode,--a.ApplicationCode ,
                        a.ApplicationDate ,
                        a.AMEmployeeID ,
                        a.EServiceUserID ,
                        a.EServiceID ,
                        a.ApplicationStateID ,
                        a.CreatedDate ,
                        a.CreatedBy ,
                        a.ModifiedDate ,
                        a.ModifiedBy ,
                        0 AttachmentTypeID ,
                        '' AttachmentTypeNameEn ,
                        '' AttachmentTypeNameAr ,
                        NULL ApplicationAttachmentFile ,
                        'http://handasahstgapi.am.gov.ae:505/Handlers/FileDownloader/FileDownloader.ashx?AppID='
                        + CAST(@applicationId AS VARCHAR) + '&TypID=21' ApplicationAttachmentFileLink ,
                        bp.BuildinPermitIssueDate AS [Issuance Date] ,
                        bp.BuildingPermitExpiryDate AS [Expiry Date] ,
                        p.ParcelCode ,
                        p.ParcelGateLevel ,
                        p.ParcelArea ,
                        bp.BuildingPermitCode ,
                        SUBSTRING(CONVERT(VARCHAR, p.ParcelCode),
                                  LEN(p.ParcelCode) - 3, LEN(p.ParcelCode)) AS PlotNo ,
                        p.ParcelCode AS [Parcel No] ,
                        ISNULL(bp.BuildingPermitCode, '220220170098') AS [Permit No] ,
                        ( SELECT TOP ( 1 )
                                    parentBP.BuildingPermitCode
                          FROM      BuildingPermit AS parentBP
                          WHERE     ( parentBP.ParcelID = bp.ParcelID
                                      AND parentBP.BuildingPermitCode IS NOT NULL
                                    )
                          ORDER BY  BuildingPermitID ASC
                        ) AS [Primary Permit No] ,
                        ' ' AS [Old Permit No] ,
                       CASE WHEN @EServiceID =1 THEN 'NEW' ELSE CASE WHEN @EServiceID=3 THEN 'ADD' ELSE 'EXIST' END END AS [Permit Type En] ,
                         CASE WHEN @EServiceID =1 THEN N'ÌÏíÏ' ELSE CASE WHEN @EServiceID=3 THEN N'ÅÖÇÝÉ' ELSE N'ÞÇÆã' END END  AS [Permit Type Ar] ,
                        ( SELECT    STUFF(( SELECT  ', ' + ior.OwnerNameEn
                                            FROM    IndividualOwner AS ior
                                            WHERE   ior.BuildingPermitID = bp.BuildingPermitID
                                          FOR
                                            XML PATH('')
                                          ), 1, 1, '')
                        ) AS [iOwner En] ,
                        ( SELECT    STUFF(( SELECT  ', ' + iorAr.OwnerNameAr
                                            FROM    IndividualOwner AS iorAr
                                            WHERE   iorAr.BuildingPermitID = bp.BuildingPermitID
                                          FOR
                                            XML PATH('')
                                          ), 1, 1, '')
                        ) AS [iOwner Ar] ,
                        ( SELECT    STUFF(( SELECT  ', '
                                                    + gor.GovernmentOwnerNameEn
                                            FROM    GovernmentOwner AS gor
                                            WHERE   gor.BuildingPermitID = bp.BuildingPermitID
                                          FOR
                                            XML PATH('')
                                          ), 1, 1, '')
                        ) AS [gOwner En] ,
                        ( SELECT    STUFF(( SELECT  ', '
                                                    + gorAr.GovernmentOwnerNameAr
                                            FROM    GovernmentOwner AS gorAr
                                            WHERE   gorAr.BuildingPermitID = bp.BuildingPermitID
                                          FOR
                                            XML PATH('')
                                          ), 1, 1, '')
                        ) AS [gOwner Ar] ,
                        ( SELECT    STUFF(( SELECT  ', '
                                                    + cor.CompanyOwnerNameEn
                                            FROM    CompanyOwner AS cor
                                            WHERE   cor.BuildingPermitID = bp.BuildingPermitID
                                          FOR
                                            XML PATH('')
                                          ), 1, 1, '')
                        ) AS [cOwner En] ,
                        ( SELECT    STUFF(( SELECT  ', '
                                                    + corAr.CompanyOwnerNameAr
                                            FROM    CompanyOwner AS corAr
                                            WHERE   corAr.BuildingPermitID = bp.BuildingPermitID
                                          FOR
                                            XML PATH('')
                                          ), 1, 1, '')
                        ) AS [cOwner Ar] ,
                        ( SELECT    OwnerNameAr
                          FROM      dbo.UdfGetOwnerByParcelCode(bp.BuildingPermitID)
                        ) AS OwnerNameArTemp ,
                        ( SELECT    OwnerNameEn
                          FROM      dbo.UdfGetOwnerByParcelCode(bp.BuildingPermitID)
                        ) AS OwnerNameEnTemp ,
                        d.DistrictNameEn AS [District En] ,
                        d.DistrictNameAr AS [District Ar] ,
                        s.SectorNameEn AS [Sector En] ,
                        s.SectorNameAr AS [Sector Ar] ,
                        c.CityNameEn AS [City En] ,
                        c.CityNameAr AS [City Ar] ,
                        pj.ProjectDescription AS [Project Description] ,
                        Designer.DesignerNameAr AS [Consultant Ar] ,
                        Designer.DesignerNameEn AS [Consultant En] ,
                        sp.SupervisorNameAr AS [Supervisor Ar] ,
                        sp.SupervisorNameEn AS [Supervisor En] ,
                        ct.ContractorNameEn AS [Main Contractor En] ,
                        ct.ContractorNameAr AS [Main Contractor Ar] ,
                        ad.AuditorNameAr AS [Consultant Auditor Ar] ,
                        ad.AuditorNameEn AS [Consultant Auditor En] ,
                        pj.ProjectNameEn   AS [Building Name] ,
                        p.ParcelGateLevel AS [Gate Level] ,
                        pj.ProjectArea AS [Total Area M2] ,
                        CONVERT(VARCHAR(10), pj.SheikhZayedHousingDate, 101)
                        + '-' + CONVERT(VARCHAR, pj.SheikhZayedHousingNumber) AS SheikhZayedHousingDate_Number ,
                       1 as IsTaskCompleted,-- atsk.IsTaskCompleted ,
                       -- atad.ApplicationTaskReviewDetailNote AS [Application Notes]
					    (select top 1 ApplicationTaskReviewDetailNote from ApplicationTaskReviewDetail where ApplicationTaskID!=(SELECT MAX(AT.ApplicationTaskID) FROM dbo.ApplicationTask AS AT WHERE AT.ApplicationID= @applicationId)
					    and ApplicationTaskID in (SELECT (AT.ApplicationTaskID)
	 FROM dbo.ApplicationTask AS AT WHERE AT.ApplicationID= @applicationId) order by ApplicationTaskReviewDetailID desc)  [Application Notes]
                FROM    [Application] AS a
                        INNER JOIN ApplicationState AS aps ON a.ApplicationStateID = aps.ApplicationStateID
                        INNER JOIN --ApplicationAttachment as apt ON a.ApplicationID = apt.ApplicationID and apt.AttachmentTypeID=1 INNER JOIN
                         --AttachmentType ON apt.AttachmentTypeID = AttachmentType.AttachmentTypeID INNER JOIN
                        IssuanceOfNewBuildingPermit AS ibp ON a.ApplicationID = ibp.ApplicationID
                        INNER JOIN BuildingPermit AS bp ON ibp.BuildingPermitID = bp.BuildingPermitID
                        INNER JOIN Parcel AS p ON bp.ParcelID = p.ParcelID
                        INNER JOIN District AS d ON p.DistrictID = d.DistrictID
                        INNER JOIN Sector AS s ON d.SectorID = s.SectorID
                        INNER JOIN City AS c ON s.CityID = c.CityID
                        INNER JOIN ParcelSubUse AS psu ON p.ParcelSubUseID = psu.ParcelSubUseID
                        INNER JOIN ParcelMainUse AS pmu ON psu.ParcelMainUseID = pmu.ParcelMainUseID
                        INNER JOIN Project AS pj ON bp.ProjectID = pj.ProjectID
						INNER JOIN Designer ON pj.DesignerID = Designer.DesignerID
                        left outer JOIN Contractor AS ct ON pj.ContractorID = ct.ContractorID
                        left outer join Supervisor AS sp ON pj.SupervisorID = sp.SupervisorID
                        left outer join Auditor AS ad ON pj.AuditorID = ad.AuditorID

                       -- INNER JOIN ApplicationTask AS atsk ON a.ApplicationID = atsk.ApplicationID
                        --INNER JOIN ApplicationTaskReviewDetail AS atad ON atsk.ApplicationTaskID = atad.ApplicationTaskID
                      
                        --LEFT OUTER JOIN Owner ON Owner.ParcelID = p.ParcelID
                WHERE   ( aps.ApplicationStateID = 8 ) --AND (AttachmentType.AttachmentTypeID = 21) /*AND (atsk.IsTaskCompleted = 1) sajid told me to comment temp 21feb17*/
                        AND a.ApplicationID = @applicationId
               -- ORDER BY atsk.ApplicationTaskID DESC;
            END;
        ELSE
            IF @EServiceID = 7
                BEGIN
                    SELECT TOP 1
                            aps.ApplicationStateNameEn ,
                            a.ApplicationID ,
                            a.ApplicationCode ,
                            a.ApplicationDate ,
                            a.AMEmployeeID ,
                            a.EServiceUserID ,
                            a.EServiceID ,
                            a.ApplicationStateID ,
                            a.CreatedDate ,
                            a.CreatedBy ,
                            a.ModifiedDate ,
                            a.ModifiedBy ,
                            0 AttachmentTypeID ,
                            '' AttachmentTypeNameEn ,
                            '' AttachmentTypeNameAr ,
                            NULL ApplicationAttachmentFile ,
                            'http://handasahstgapi.am.gov.ae:505/Handlers/FileDownloader/FileDownloader.ashx?AppID='
                             + CAST( (SELECT TOP 1 ISNULL(AA.ApplicationID,isBP.ApplicationID) FROM dbo.ApplicationAttachment AS AA WHERE AA.ApplicationID=a.ApplicationID AND AA.AttachmentTypeID=21)  AS VARCHAR)
                            + '&TypID=21' ApplicationAttachmentFileLink ,
                            bp.BuildinPermitIssueDate AS [Issuance Date] ,
                            bp.BuildingPermitExpiryDate AS [Expiry Date] ,
                            p.ParcelCode ,
                            p.ParcelGateLevel ,
                            p.ParcelArea ,
                            bp.BuildingPermitCode ,
                            SUBSTRING(CONVERT(VARCHAR, p.ParcelCode),
                                      LEN(p.ParcelCode) - 3, LEN(p.ParcelCode)) AS PlotNo ,
                            p.ParcelCode AS [Parcel No] ,
                            ISNULL(bp.BuildingPermitCode, '220220170098') AS [Permit No] ,
                            ( SELECT TOP ( 1 )
                                        parentBP.BuildingPermitCode
                              FROM      BuildingPermit AS parentBP
                              WHERE     ( parentBP.ParcelID = bp.ParcelID
                                          AND parentBP.BuildingPermitCode IS NOT NULL
                                        )
                              ORDER BY  BuildingPermitID ASC
                            ) AS [Primary Permit No] ,
                            ' ' AS [Old Permit No] ,
                            'Modify' AS [Permit Type En] ,
                            N'ÊÚÏíá' AS [Permit Type Ar] ,
                            ( SELECT    STUFF(( SELECT  ', ' + ior.OwnerNameEn
                                                FROM    IndividualOwner AS ior
                                                WHERE   ior.BuildingPermitID = bp.BuildingPermitID
                                              FOR
                                                XML PATH('')
                                              ), 1, 1, '')
                            ) AS [iOwner En] ,
                            ( SELECT    STUFF(( SELECT  ', '
                                                        + iorAr.OwnerNameAr
                                                FROM    IndividualOwner AS iorAr
                                                WHERE   iorAr.BuildingPermitID = bp.BuildingPermitID
                                              FOR
                                                XML PATH('')
                                              ), 1, 1, '')
                            ) AS [iOwner Ar] ,
                            ( SELECT    STUFF(( SELECT  ', '
                                                        + gor.GovernmentOwnerNameEn
                                                FROM    GovernmentOwner AS gor
                                                WHERE   gor.BuildingPermitID = bp.BuildingPermitID
                                              FOR
                                                XML PATH('')
                                              ), 1, 1, '')
                            ) AS [gOwner En] ,
                            ( SELECT    STUFF(( SELECT  ', '
                                                        + gorAr.GovernmentOwnerNameAr
                                                FROM    GovernmentOwner AS gorAr
                                                WHERE   gorAr.BuildingPermitID = bp.BuildingPermitID
                                              FOR
                                                XML PATH('')
                                              ), 1, 1, '')
                            ) AS [gOwner Ar] ,
                            ( SELECT    STUFF(( SELECT  ', '
                                                        + cor.CompanyOwnerNameEn
                                                FROM    CompanyOwner AS cor
                                                WHERE   cor.BuildingPermitID = bp.BuildingPermitID
                                              FOR
                                                XML PATH('')
                                              ), 1, 1, '')
                            ) AS [cOwner En] ,
                            ( SELECT    STUFF(( SELECT  ', '
                                                        + corAr.CompanyOwnerNameAr
                                                FROM    CompanyOwner AS corAr
                                                WHERE   corAr.BuildingPermitID = bp.BuildingPermitID
                                              FOR
                                                XML PATH('')
                                              ), 1, 1, '')
                            ) AS [cOwner Ar] ,
                            ( SELECT    OwnerNameAr
                              FROM      dbo.UdfGetOwnerByParcelCode(bp.BuildingPermitID)
                            ) AS OwnerNameArTemp ,
                            ( SELECT    OwnerNameEn
                              FROM      dbo.UdfGetOwnerByParcelCode(bp.BuildingPermitID)
                            ) AS OwnerNameEnTemp ,
                            d.DistrictNameEn AS [District En] ,
                            d.DistrictNameAr AS [District Ar] ,
                            s.SectorNameEn AS [Sector En] ,
                            s.SectorNameAr AS [Sector Ar] ,
                            c.CityNameEn AS [City En] ,
                            c.CityNameAr AS [City Ar] ,
                            pj.ProjectDescription AS [Project Description] ,
                            Designer.DesignerNameAr AS [Consultant Ar] ,
                            Designer.DesignerNameEn AS [Consultant En] ,
                            sp.SupervisorNameAr AS [Supervisor Ar] ,
                            sp.SupervisorNameEn AS [Supervisor En] ,
                            ct.ContractorNameEn AS [Main Contractor En] ,
                            ct.ContractorNameAr AS [Main Contractor Ar] ,
                            ad.AuditorNameAr AS [Consultant Auditor Ar] ,
                            ad.AuditorNameEn AS [Consultant Auditor En] ,
                            pj.ProjectNameEn AS [Building Name] ,
                            p.ParcelGateLevel AS [Gate Level] ,
                            pj.ProjectArea AS [Total Area M2] ,
                            CONVERT(VARCHAR(10), pj.SheikhZayedHousingDate, 101)
                            + '-'
                            + CONVERT(VARCHAR, pj.SheikhZayedHousingNumber) AS SheikhZayedHousingDate_Number ,
                            atsk.IsTaskCompleted ,
                            atad.ApplicationTaskReviewDetailNote AS [Application Notes]
                    FROM    [Application] AS a
                            INNER JOIN ApplicationState AS aps ON a.ApplicationStateID = aps.ApplicationStateID
                            INNER JOIN --ApplicationAttachment as apt ON a.ApplicationID = apt.ApplicationID and apt.AttachmentTypeID=1 INNER JOIN
                         --AttachmentType ON apt.AttachmentTypeID = AttachmentType.AttachmentTypeID INNER JOIN
                            ModificationOfBuildingPermit AS mdbp ON a.ApplicationID = mdbp.ApplicationID
                            INNER JOIN BuildingPermit AS bp ON mdbp.BuildingPermitID = bp.BuildingPermitID
                            INNER JOIN IssuanceOfNewBuildingPermit isBP ON isBP.BuildingPermitID = bp.BuildingPermitID
                            INNER JOIN Parcel AS p ON bp.ParcelID = p.ParcelID
                            INNER JOIN District AS d ON p.DistrictID = d.DistrictID
                            INNER JOIN Sector AS s ON d.SectorID = s.SectorID
                            INNER JOIN City AS c ON s.CityID = c.CityID
                            INNER JOIN ParcelSubUse AS psu ON p.ParcelSubUseID = psu.ParcelSubUseID
                            INNER JOIN ParcelMainUse AS pmu ON psu.ParcelMainUseID = pmu.ParcelMainUseID
                            INNER JOIN Project AS pj ON bp.ProjectID = pj.ProjectID
                            left outer join Contractor AS ct ON pj.ContractorID = ct.ContractorID
                            left outer join Supervisor AS sp ON pj.SupervisorID = sp.SupervisorID
                            left outer join Auditor AS ad ON pj.AuditorID = ad.AuditorID
                            INNER JOIN ApplicationTask AS atsk ON a.ApplicationID = atsk.ApplicationID
                            INNER JOIN ApplicationTaskReviewDetail AS atad ON atsk.ApplicationTaskID = atad.ApplicationTaskID
                            INNER JOIN Designer ON pj.DesignerID = Designer.DesignerID
                         --   LEFT OUTER JOIN Owner ON Owner.ParcelID = p.ParcelID
                    WHERE   ( aps.ApplicationStateID = 8 ) --AND (AttachmentType.AttachmentTypeID = 21) /*AND (atsk.IsTaskCompleted = 1) sajid told me to comment temp 21feb17*/
                            AND a.ApplicationID = @applicationId
                    ORDER BY atsk.ApplicationTaskID DESC;
                END;
            ELSE
                IF @EServiceID = 17
                    BEGIN
                        SELECT TOP 1
                                aps.ApplicationStateNameEn ,
                                a.ApplicationID ,
                                a.ApplicationCode ,
                                a.ApplicationDate ,
                                a.AMEmployeeID ,
                                a.EServiceUserID ,
                                a.EServiceID ,
                                a.ApplicationStateID ,
                                a.CreatedDate ,
                                a.CreatedBy ,
                                a.ModifiedDate ,
                                a.ModifiedBy ,
                                0 AttachmentTypeID ,
                                '' AttachmentTypeNameEn ,
                                '' AttachmentTypeNameAr ,
                                NULL ApplicationAttachmentFile ,
                                'http://handasahstgapi.am.gov.ae:505/Handlers/FileDownloader/FileDownloader.ashx?AppID='
                               + CAST( (SELECT TOP 1 ISNULL(AA.ApplicationID,isBP.ApplicationID) FROM dbo.ApplicationAttachment AS AA WHERE AA.ApplicationID=a.ApplicationID AND AA.AttachmentTypeID=21)  AS VARCHAR)
                                + '&TypID=21' ApplicationAttachmentFileLink ,
                                bp.BuildinPermitIssueDate AS [Issuance Date] ,
                                bp.BuildingPermitExpiryDate AS [Expiry Date] ,
                                p.ParcelCode ,
                                p.ParcelGateLevel ,
                                p.ParcelArea ,
                                bp.BuildingPermitCode ,
                                SUBSTRING(CONVERT(VARCHAR, p.ParcelCode),
                                          LEN(p.ParcelCode) - 3,
                                          LEN(p.ParcelCode)) AS PlotNo ,
                                p.ParcelCode AS [Parcel No] ,
                                ISNULL(bp.BuildingPermitCode, '220220170098') AS [Permit No] ,
                                ( SELECT TOP ( 1 )
                                            parentBP.BuildingPermitCode
                                  FROM      BuildingPermit AS parentBP
                                  WHERE     ( parentBP.ParcelID = bp.ParcelID
                                              AND parentBP.BuildingPermitCode IS NOT NULL
                                            )
                                  ORDER BY  BuildingPermitID ASC
                                ) AS [Primary Permit No] ,
                                ' ' AS [Old Permit No] ,
                                'Renew' AS [Permit Type En] ,
                                N'ÊÌÏíÏ' AS [Permit Type Ar] ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + ior.OwnerNameEn
                                                    FROM    IndividualOwner AS ior
                                                    WHERE   ior.BuildingPermitID = bp.BuildingPermitID
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS [iOwner En] ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + iorAr.OwnerNameAr
                                                    FROM    IndividualOwner AS iorAr
                                                    WHERE   iorAr.BuildingPermitID = bp.BuildingPermitID
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS [iOwner Ar] ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + gor.GovernmentOwnerNameEn
                                                    FROM    GovernmentOwner AS gor
                                                    WHERE   gor.BuildingPermitID = bp.BuildingPermitID
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS [gOwner En] ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + gorAr.GovernmentOwnerNameAr
                                                    FROM    GovernmentOwner AS gorAr
                                                    WHERE   gorAr.BuildingPermitID = bp.BuildingPermitID
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS [gOwner Ar] ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + cor.CompanyOwnerNameEn
                                                    FROM    CompanyOwner AS cor
                                                    WHERE   cor.BuildingPermitID = bp.BuildingPermitID
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS [cOwner En] ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + corAr.CompanyOwnerNameAr
                                                    FROM    CompanyOwner AS corAr
                                                    WHERE   corAr.BuildingPermitID = bp.BuildingPermitID
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS [cOwner Ar] ,
                                ( SELECT    OwnerNameAr
                                  FROM      dbo.UdfGetOwnerByParcelCode(bp.BuildingPermitID)
                                ) AS OwnerNameArTemp ,
                                ( SELECT    OwnerNameEn
                                  FROM      dbo.UdfGetOwnerByParcelCode(bp.BuildingPermitID)
                                ) AS OwnerNameEnTemp ,
                                d.DistrictNameEn AS [District En] ,
                                d.DistrictNameAr AS [District Ar] ,
                                s.SectorNameEn AS [Sector En] ,
                                s.SectorNameAr AS [Sector Ar] ,
                                c.CityNameEn AS [City En] ,
                                c.CityNameAr AS [City Ar] ,
                                pj.ProjectDescription AS [Project Description] ,
                                Designer.DesignerNameAr AS [Consultant Ar] ,
                                Designer.DesignerNameEn AS [Consultant En] ,
                                sp.SupervisorNameAr AS [Supervisor Ar] ,
                                sp.SupervisorNameEn AS [Supervisor En] ,
                                ct.ContractorNameEn AS [Main Contractor En] ,
                                ct.ContractorNameAr AS [Main Contractor Ar] ,
                                ad.AuditorNameAr AS [Consultant Auditor Ar] ,
                                ad.AuditorNameEn AS [Consultant Auditor En] ,
                                pj.ProjectNameEn AS [Building Name] ,
                                p.ParcelGateLevel AS [Gate Level] ,
                                pj.ProjectArea AS [Total Area M2] ,
                                CONVERT(VARCHAR(10), pj.SheikhZayedHousingDate, 101)
                                + '-'
                                + CONVERT(VARCHAR, pj.SheikhZayedHousingNumber) AS SheikhZayedHousingDate_Number ,
                                atsk.IsTaskCompleted ,
                                atad.ApplicationTaskReviewDetailNote AS [Application Notes]
                        FROM    [Application] AS a
                                INNER JOIN ApplicationState AS aps ON a.ApplicationStateID = aps.ApplicationStateID
                                INNER JOIN --ApplicationAttachment as apt ON a.ApplicationID = apt.ApplicationID and apt.AttachmentTypeID=1 INNER JOIN
                         --AttachmentType ON apt.AttachmentTypeID = AttachmentType.AttachmentTypeID INNER JOIN
                                dbo.RenewOfBuildingPermit AS ROBP ON a.ApplicationID = ROBP.ApplicationID
                                INNER JOIN BuildingPermit AS bp ON ROBP.BuildingPermitID = bp.BuildingPermitID
                                INNER JOIN IssuanceOfNewBuildingPermit isBP ON isBP.BuildingPermitID = bp.BuildingPermitID
                                INNER JOIN Parcel AS p ON bp.ParcelID = p.ParcelID
                                INNER JOIN District AS d ON p.DistrictID = d.DistrictID
                                INNER JOIN Sector AS s ON d.SectorID = s.SectorID
                                INNER JOIN City AS c ON s.CityID = c.CityID
                                INNER JOIN ParcelSubUse AS psu ON p.ParcelSubUseID = psu.ParcelSubUseID
                                INNER JOIN ParcelMainUse AS pmu ON psu.ParcelMainUseID = pmu.ParcelMainUseID
                                INNER JOIN Project AS pj ON bp.ProjectID = pj.ProjectID
								INNER JOIN ApplicationTask AS atsk ON a.ApplicationID = atsk.ApplicationID
                                left JOIN Contractor AS ct ON pj.ContractorID = ct.ContractorID
                                left JOIN Supervisor AS sp ON pj.SupervisorID = sp.SupervisorID
                                left JOIN Auditor AS ad ON pj.AuditorID = ad.AuditorID
                                
                                left JOIN ApplicationTaskReviewDetail AS atad ON atsk.ApplicationTaskID = atad.ApplicationTaskID
                                left JOIN Designer ON pj.DesignerID = Designer.DesignerID
                                LEFT OUTER JOIN Owner ON Owner.ParcelID = p.ParcelID
                        WHERE   ( aps.ApplicationStateID = 8 ) --AND (AttachmentType.AttachmentTypeID = 21) /*AND (atsk.IsTaskCompleted = 1) sajid told me to comment temp 21feb17*/
                                AND a.ApplicationID = @applicationId
                        ORDER BY atsk.ApplicationTaskID DESC;
                    END;

                ELSE
                    IF @EServiceID = 18
                        BEGIN
                            SELECT TOP 1
                                    aps.ApplicationStateNameEn ,
                                    a.ApplicationID ,
                                    a.ApplicationCode ,
                                    a.ApplicationDate ,
                                    a.AMEmployeeID ,
                                    a.EServiceUserID ,
                                    a.EServiceID ,
                                    a.ApplicationStateID ,
                                    a.CreatedDate ,
                                    a.CreatedBy ,
                                    a.ModifiedDate ,
                                    a.ModifiedBy ,
                                    0 AttachmentTypeID ,
                                    '' AttachmentTypeNameEn ,
                                    '' AttachmentTypeNameAr ,
                                    NULL ApplicationAttachmentFile ,
                                    'http://handasahstgapi.am.gov.ae:505/Handlers/FileDownloader/FileDownloader.ashx?AppID='
                                    + CAST(isBP.ApplicationID AS VARCHAR)
                                    + '&TypID=21' ApplicationAttachmentFileLink ,
                                    bp.BuildinPermitIssueDate AS [Issuance Date] ,
                                    bp.BuildingPermitExpiryDate AS [Expiry Date] ,
                                    p.ParcelCode ,
                                    p.ParcelGateLevel ,
                                    p.ParcelArea ,
                                    bp.BuildingPermitCode ,
                                    SUBSTRING(CONVERT(VARCHAR, p.ParcelCode),
                                              LEN(p.ParcelCode) - 3,
                                              LEN(p.ParcelCode)) AS PlotNo ,
                                    p.ParcelCode AS [Parcel No] ,
                                    ISNULL(bp.BuildingPermitCode,
                                           '220220170098') AS [Permit No] ,
                                    ( SELECT TOP ( 1 )
                                                parentBP.BuildingPermitCode
                                      FROM      BuildingPermit AS parentBP
                                      WHERE     ( parentBP.ParcelID = bp.ParcelID
                                                  AND parentBP.BuildingPermitCode IS NOT NULL
                                                )
                                      ORDER BY  BuildingPermitID ASC
                                    ) AS [Primary Permit No] ,
                                    ' ' AS [Old Permit No] ,
                                    'Cancel' AS [Permit Type En] ,
                                    N'ÅáÛÇÁ' AS [Permit Type Ar] ,
                                    ( SELECT    STUFF(( SELECT
                                                              ', '
                                                              + ior.OwnerNameEn
                                                        FROM  IndividualOwner
                                                              AS ior
                                                        WHERE ior.BuildingPermitID = bp.BuildingPermitID
                                                      FOR
                                                        XML PATH('')
                                                      ), 1, 1, '')
                                    ) AS [iOwner En] ,
                                    ( SELECT    STUFF(( SELECT
                                                              ', '
                                                              + iorAr.OwnerNameAr
                                                        FROM  IndividualOwner
                                                              AS iorAr
                                                        WHERE iorAr.BuildingPermitID = bp.BuildingPermitID
                                                      FOR
                                                        XML PATH('')
                                                      ), 1, 1, '')
                                    ) AS [iOwner Ar] ,
                                    ( SELECT    STUFF(( SELECT
                                                              ', '
                                                              + gor.GovernmentOwnerNameEn
                                                        FROM  GovernmentOwner
                                                              AS gor
                                                        WHERE gor.BuildingPermitID = bp.BuildingPermitID
                                                      FOR
                                                        XML PATH('')
                                                      ), 1, 1, '')
                                    ) AS [gOwner En] ,
                                    ( SELECT    STUFF(( SELECT
                                                              ', '
                                                              + gorAr.GovernmentOwnerNameAr
                                                        FROM  GovernmentOwner
                                                              AS gorAr
                                                        WHERE gorAr.BuildingPermitID = bp.BuildingPermitID
                                                      FOR
                                                        XML PATH('')
                                                      ), 1, 1, '')
                                    ) AS [gOwner Ar] ,
                                    ( SELECT    STUFF(( SELECT
                                                              ', '
                                                              + cor.CompanyOwnerNameEn
                                                        FROM  CompanyOwner AS cor
                                                        WHERE cor.BuildingPermitID = bp.BuildingPermitID
                                                      FOR
                                                        XML PATH('')
                                                      ), 1, 1, '')
                                    ) AS [cOwner En] ,
                                    ( SELECT    STUFF(( SELECT
                                                              ', '
                                                              + corAr.CompanyOwnerNameAr
                                                        FROM  CompanyOwner AS corAr
                                                        WHERE corAr.BuildingPermitID = bp.BuildingPermitID
                                                      FOR
                                                        XML PATH('')
                                                      ), 1, 1, '')
                                    ) AS [cOwner Ar] ,
                                    ( SELECT    OwnerNameAr
                                      FROM      dbo.UdfGetOwnerByParcelCode(bp.BuildingPermitID)
                                    ) AS OwnerNameArTemp ,
                                    ( SELECT    OwnerNameEn
                                      FROM      dbo.UdfGetOwnerByParcelCode(bp.BuildingPermitID)
                                    ) AS OwnerNameEnTemp ,
                                    d.DistrictNameEn AS [District En] ,
                                    d.DistrictNameAr AS [District Ar] ,
                                    s.SectorNameEn AS [Sector En] ,
                                    s.SectorNameAr AS [Sector Ar] ,
                                    c.CityNameEn AS [City En] ,
                                    c.CityNameAr AS [City Ar] ,
                                    pj.ProjectDescription AS [Project Description] ,
                                    Designer.DesignerNameAr AS [Consultant Ar] ,
                                    Designer.DesignerNameEn AS [Consultant En] ,
                                    sp.SupervisorNameAr AS [Supervisor Ar] ,
                                    sp.SupervisorNameEn AS [Supervisor En] ,
                                    ct.ContractorNameEn AS [Main Contractor En] ,
                                    ct.ContractorNameAr AS [Main Contractor Ar] ,
                                    ad.AuditorNameAr AS [Consultant Auditor Ar] ,
                                    ad.AuditorNameEn AS [Consultant Auditor En] ,
                                    pj.ProjectNameEn AS [Building Name] ,
                                    p.ParcelGateLevel AS [Gate Level] ,
                                    pj.ProjectArea AS [Total Area M2] ,
                                    CONVERT(VARCHAR(10), pj.SheikhZayedHousingDate, 101)
                                    + '-'
                                    + CONVERT(VARCHAR, pj.SheikhZayedHousingNumber) AS SheikhZayedHousingDate_Number ,
                                    atsk.IsTaskCompleted ,
                                    atad.ApplicationTaskReviewDetailNote AS [Application Notes]
                            FROM    [Application] AS a
                                    INNER JOIN ApplicationState AS aps ON a.ApplicationStateID = aps.ApplicationStateID
                                    INNER JOIN --ApplicationAttachment as apt ON a.ApplicationID = apt.ApplicationID and apt.AttachmentTypeID=1 INNER JOIN
                         --AttachmentType ON apt.AttachmentTypeID = AttachmentType.AttachmentTypeID INNER JOIN
                                    dbo.CancellationOfBuildingPermit AS ROBP ON a.ApplicationID = ROBP.ApplicationID
                                    INNER JOIN BuildingPermit AS bp ON ROBP.BuildingPermitID = bp.BuildingPermitID
                                    INNER JOIN IssuanceOfNewBuildingPermit isBP ON isBP.BuildingPermitID = bp.BuildingPermitID
                                    INNER JOIN Parcel AS p ON bp.ParcelID = p.ParcelID
                                    INNER JOIN District AS d ON p.DistrictID = d.DistrictID
                                    INNER JOIN Sector AS s ON d.SectorID = s.SectorID
                                    INNER JOIN City AS c ON s.CityID = c.CityID
                                    INNER JOIN ParcelSubUse AS psu ON p.ParcelSubUseID = psu.ParcelSubUseID
                                    INNER JOIN ParcelMainUse AS pmu ON psu.ParcelMainUseID = pmu.ParcelMainUseID
                                    INNER JOIN Project AS pj ON bp.ProjectID = pj.ProjectID
                                    left outer join Contractor AS ct ON pj.ContractorID = ct.ContractorID
                                    left outer join Supervisor AS sp ON pj.SupervisorID = sp.SupervisorID
                                    left outer join Auditor AS ad ON pj.AuditorID = ad.AuditorID
                                    INNER JOIN ApplicationTask AS atsk ON a.ApplicationID = atsk.ApplicationID
                                    INNER JOIN ApplicationTaskReviewDetail AS atad ON atsk.ApplicationTaskID = atad.ApplicationTaskID
                                    INNER JOIN Designer ON pj.DesignerID = Designer.DesignerID
                                    --LEFT OUTER JOIN Owner ON Owner.ParcelID = p.ParcelID
                            WHERE   ( aps.ApplicationStateID = 8 ) --AND (AttachmentType.AttachmentTypeID = 21) /*AND (atsk.IsTaskCompleted = 1) sajid told me to comment temp 21feb17*/
                                    AND a.ApplicationID = @applicationId
                            ORDER BY atsk.ApplicationTaskID DESC;
                        END;
    END;
GO
