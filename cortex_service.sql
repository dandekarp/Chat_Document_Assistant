create or replace CORTEX SEARCH SERVICE CC_SEARCH_SERVICE_SS
ON chunk
ATTRIBUTES category
warehouse = COMPUTE_WH
TARGET_LAG = '1 minute'
as (
    select
        chunk,
        relative_path,
        file_url,
        category
    from docs_chunks_table
);

--name of the service is CC_SEARCH_SERVICE_SS
--The service will use the column chunk to create embeddings and perform retrieval based on similarity search
--The column category could be used as a filter
--To keep this service updated the warehosue COMPUTE_WH will be used. 
--This name is used by default in trial accounts but you may want to type the name of your own warehouse.
--The service will be refreshed every minute
--The data retrieved will contain the chunk, relative_path, file_url and category


--This is all what we have to do. There is no need here to create embeddings as that is done automatically. 
--We can now use the API to query the service.