
<!-- .slide: style="background-color: coral;" -->
# Dynamodb

- No self managed server it is service 
- Actually NoSQL table as sevice 
- manual/Auto provision scale in/out or on demand 
- multiple back up : PIT recovery 
- CDC change capture/event driven integrate (DynamoDB Stream)

---

# DynamoDB Table 

![[Dynamodb_table.excalidraw]]

---

## DynamoDB Operation 

![[Dynamodb_query_scan.excalidraw]]

---

## Query 
---
### Query with PK 
![[dynamodb_query_pk.svg]]

---

### Query with PK and Filter

![[dynamodb_query_filter.svg]]


---

### DynamoDB table stream

- Ordered list of item change in table (kinesis stream)
- 24 hours rolling window
- Enable per table 
- record INSER/UPDATE/DELETE 
- Multiple view type for change 
  - KEY ONLY 
  - OLD
  - NEW
  - OLD_NEW 


---

## END