--#!/usr/bin/env psql

CREATE OR REPLACE FUNCTION public.CloserThan(geom0 geometry, distance DOUBLE PRECISION, type_name0 VARCHAR)
  RETURNS geometry[]                                                                                   
  LANGUAGE plpgsql                                                                                   
  AS $function$ 
  DECLARE nearpoint geometry[];
  BEGIN  
    select array(SELECT geom FROM reportes WHERE ST_Distance(geom, geom0)<=distance AND type_name=type_name0 INTO nearpoint);
    RETURN nearpoint;
  END;
  $function$;
COMMIT;

CREATE OR REPLACE FUNCTION public.HeatMapValue(geom0 geometry, distance DOUBLE PRECISION, type_name0 VARCHAR)
  RETURNS numeric                                                                                   
  LANGUAGE plpgsql                                                                                   
  AS $function$ 
  DECLARE maxcount NUMERIC;
  DECLARE heatval NUMERIC;
  BEGIN  
    SELECT array_length(CloserThan(geom,distance,type_name),1) as count0 FROM reportes WHERE type_name=type_name0 ORDER BY count0 DESC LIMIT 1 INTO maxcount;
    SELECT COALESCE(count(CloserThan(geom,distance,type_name))/maxcount,0) FROM reportes WHERE geom=geom0 AND type_name=type_name0 INTO heatval;
    RETURN heatval;
  END;
  $function$;
COMMIT;