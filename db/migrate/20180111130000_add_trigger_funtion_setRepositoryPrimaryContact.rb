class AddTypeToCourses < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION setRepositoryPrimaryContact()
        RETURNS trigger AS
      $BODY$
      DECLARE
          course_id_holder              INTEGER;
          staff_service_id_holder       INTEGER;
      BEGIN
       course_id_holder := NEW.id;
       IF NEW.repository_id <> OLD.repository_id  and NEW.repository_id in 
        (select repository_id from repositories_users ru2 left join users u on u.id = ru2.user_id where staff = true group by repository_id having count(ru2.user_id) = 1)
       THEN
      update courses 
      set primary_contact_id = (select user_id from repositories_users ru1 inner join users u1 on u1.id = ru1.user_id where repository_id in (select repository_id from repositories_users ru2 left join users u2 on u2.id = ru2.user_id where staff = true group by repository_id having count(ru2.user_id) = 1) and staff = true and repository_id = NEW.repository_id limit 1)
      where id=NEW.id;
       END IF;
       IF NEW.repository_id <> OLD.repository_id  and NEW.repository_id in 
        (select repository_id from repositories_staff_services group by repository_id having count(staff_service_id) = 1)
       THEN
       select staff_service_id into staff_service_id_holder from repositories_staff_services where repository_id = NEW.repository_id;
       insert into courses_staff_services
        (course_id, staff_service_id)
        VALUES
        (course_id_holder,staff_service_id_holder);
        END IF;
        
       RETURN NEW;
      END;
      $BODY$

      LANGUAGE plpgsql VOLATILE
      COST 100;
      CREATE TRIGGER courseRepositoryChangeSetsPrimaryContact
        AFTER UPDATE
        ON courses
        FOR EACH ROW
        EXECUTE PROCEDURE setRepositoryPrimaryContact();
    SQL
  end
end
