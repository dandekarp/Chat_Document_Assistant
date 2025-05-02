------------------------------------------------------------------------------------------------

-- In this file, we will be creating table to store the chunks for each PDF
-- The function (SNOWFLAKE.CORTEX.PARSE_DOCUMENT) will be used to read the PDF documents directly from the staging area

------------------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE DOCS_CHUNKS_TABLE (
    RELATIVE_PATH VARCHAR(16777216),    -- relative path to the PDF file
    SIZE NUMBER(38,0),                  -- size of the PDF
    FILE_URL VARCHAR(16777216),         -- URL for the PDF
    SCOPED_FILE_URL VARCHAR(16777216),  -- scoped URL (choose one depending upon the use-case)
    CHUNK VARCHAR(16777216),            -- piece of text
    CATEGORY VARCHAR(16777216)          -- will hold document category to enable filtering
);

insert into docs_chunks_table (relative_path, size, file_url, scoped_file_url, chunk)
    select
        relative_path,
        size,
        file_url,
        build_scoped_file_url( @docs, relative_path) as scoped_file_url,
        func.chunk as chunk
    from
        directory(@docs),
        TABLE(text_chunker(to_varchar(SNOWFLAKE.CORTEX.PARSE_DOCUMENT(@docs,
                                        relative_path, {'mode': 'LAYOUT'})))) AS func;

-- 

CREATE OR REPLACE TEMPORARY TABLE docs_category AS
WITH unique_documents AS (
    SELECT
        DISTINCT relative_path
    FROM 
        docs_chunks_table
),
docs_category_cte AS (
    SELECT
        relative_path,
        TRIM(snowflake.CORTEX.COMPLETE (
            'llama3-70b',
            'Given the name of the file between <file> and </file> determine if it is related to bikes or snow. Use only one word <file> ' || relative_path || '</file>'
        ), '\n') AS category
    FROM
        unique_documents
)
SELECT 
    *
FROM 
    docs_category_cte;

select category from docs_category group by category;

select * from docs_category;

update docs_chunks_table
    SET category = docs_category.category
    FROM docs_category
    WHERE docs_chunks_table.relative_path = docs_category.relative_path;

select * from docs_chunks_table;