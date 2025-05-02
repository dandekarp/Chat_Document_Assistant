CREATE OR REPLACE DATABASE CORTEX_SEARCH_DOCS;

CREATE SCHEMA DATA;

CREATE OR REPLACE FUNCTION text_chunker(pdf_text string)
returns table (chunk varchar)
language python
runtime_version = '3.9'
handler = 'text_chunker'
packages = ('snowflake-snowpark-python', 'langchain')
as
$$

from snowflake.snowpark.types import StringType, StructField, StructType
from langchain.text_splitter import RecursiveCharacterTextSplitter
import pandas as pd

class text_chunker:
    def process(self, pdf_text: str):
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size = 1512, 
            chunk_overlap  = 256,
            length_function = len
        )
    
        chunks = text_splitter.split_text(pdf_text)
        df = pd.DataFrame(chunks, columns=['chunks'])
        
        yield from df.itertuples(index=False, name=None)

$$;

create or replace stage docs ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') DIRECTORY = ( ENABLE = true );

-----------------------------------------------------------------------------------------------------------

-- upload the documents / user manuals in pdf format to the stage via COPY command or via Snowsight Web UI

-----------------------------------------------------------------------------------------------------------
ls @docs;