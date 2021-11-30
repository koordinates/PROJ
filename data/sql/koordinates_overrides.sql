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

/* 
 Add concatenated transform for AGD66 to GDA2020
 */
INSERT INTO
    concatenated_operation (
        auth_name,
        code,
        name,
        description,
        source_crs_auth_name,
        source_crs_code,
        target_crs_auth_name,
        target_crs_code,
        accuracy,
        operation_version,
        deprecated
    )
VALUES
    (
        'KX',
        1000,
        'AGD66 to GDA2020 via GDA94',
        '',
        'EPSG',
        4202,
        'EPSG',
        7844,
        0.5099,
        1,
        false
    );

-- step 1
-- DERIVED_FROM(EPSG):1803, AGD66 to GDA94 (11), 0.5 m
INSERT INTO
    concatenated_operation_step (
        operation_auth_name,
        operation_code,
        step_number,
        step_auth_name,
        step_code
    )
VALUES
    (
        'KX',
        1000,
        1,
        'EPSG',
        1803
    );

-- step 2
-- DERIVED_FROM(EPSG):8447, GDA94 to GDA2020 (2), 0.0099 m
INSERT INTO
    concatenated_operation_step (
        operation_auth_name,
        operation_code,
        step_number,
        step_auth_name,
        step_code
    )
VALUES
    (
        'KX',
        1000,
        2,
        'EPSG',
        8447
    );

INSERT INTO
    usage (
        auth_name,
        code,
        object_table_name,
        object_auth_name,
        object_code,
        extent_auth_name,
        extent_code,
        scope_auth_name,
        scope_code
    )
VALUES
    (
        'KX',
        1000,
        'concatenated_operation',
        'KX',
        1000,
        'EPSG',
        2575,
        'EPSG',
        1234
    );

-- TODO: perhaps we need to insert into `other_transformation` table too?