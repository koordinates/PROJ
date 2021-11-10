-- This file is hand generated
--
-- When transforming from GDA2020 to WGS84,
-- use the null transform rather than grid or 7-param transforms
UPDATE
    helmert_transformation_table
SET
    accuracy = 0.0299
WHERE
    auth_name = 'EPSG'
    AND code = 8450;

--
-- When transforming from GDA94 to GDA2020,
-- use the distortion+conformal grid in preference to the conformal-only grid.
UPDATE
    grid_transformation
SET
    accuracy = 0.0099
WHERE
    auth_name = 'EPSG'
    AND code = 8447;

/*
 These three transforms from GDA94 to WGS84 are defined:
 * EPSG:9688, GDA94 to WGS 84 (2), 3.0 m, Australia including Lord Howe Island, Macquarie Island, Ashmore and Cartier Islands, Christmas Island, Cocos (Keeling) Islands, Norfolk Island. All onshore and offshore.
 * EPSG:1150, GDA94 to WGS 84 (1), 3.0 m, Australia including Lord Howe Island, Macquarie Island, Ashmore and Cartier Islands, Christmas Island, Cocos (Keeling) Islands, Norfolk Island. All onshore and offshore.
 * DERIVED_FROM(EPSG):9689, GDA94 to WGS 84 (3), 3.0 m, Australia - Australian Capital Territory; New South Wales; Northern Territory; Queensland; South Australia; Tasmania; Western Australia; Victoria.
 
 Of these, the last one is what we want: When projecting from GDA94 to WGS84, assume WGS84 equivalence with GDA2020.
 Then prioritise the transformation using the conformal+distortion grid followed by a null transform.
 
 So we prioritise that transform by improving its accuracy slightly:
 */
UPDATE
    grid_transformation
SET
    accuracy = 2.99
WHERE
    auth_name = 'EPSG'
    AND code = 9689;

-- and this one makes no sense; GDA94 to WGS84 shouldn't be a null transform.
-- setting the accuracy to null prevents PROJ from choosing this transform over another one.
update
    helmert_transformation_table
set
    accuracy = NULL
where
    auth_name = 'EPSG'
    and code = 1150;