class UrlConstructController < ApplicationController
  # This class file has all the methods required to construct the url's
  # and parse the json files into the database models.
  # All other models should be able to refer to the database models
  # instead of the sfu api.
  require 'json'
  require 'open-uri'
  require 'httparty'

  @@base = 'http://www.sfu.ca/bin/wcm/course-outlines?'

  def index


    @forView = [1,2,3]

  end


  def url2016FallCourses
    filler_array = []

    urlYear = "2016"
    urlSeason = "fall"
    instage_season_url = @@base + urlYear + "/" + urlSeason

    urlFalculty(instage_season_url)


      @AllFalculty.each do |falculty|
          instage_falculty_url = instage_season_url + "/" + falculty.dSubject
          urlCourse(instage_falculty_url)


          @AllCourse.each do |course|
            instage_course_url = instage_falculty_url + "/" + course.dCourseNumber
            urlSection(instage_course_url)


            @AllSection.each do |section|
              instage_section_url = instage_course_url + "/" + section.dSectionNumber
              urlDetail(instage_section_url)




                @AllDetail.each do |detail|



                  if (detail.sectioncode == "LEC" || detail.sectioncode == "SEM" || detail.sectioncode == "PRA" || detail.sectioncode == "STD" || detail.sectioncode == "WKS")
                    @creating_new_course = Course.new("calender" => detail.calender,
                                                     "designation" => detail.dDesignation,
                                                     "instructor" => detail.dProfessor,
                                                     "faculty" => falculty.dSubject,
                                                     "number" => course.dCourseNumber,
                                                     "year" => urlYear,
                                                     "semester" => urlSeason,
                                                     "section" => section.dSectionNumber,
                                                     "CourseUrl" => instage_section_url,
                                                     "schedule" => detail.DSchedule,
                                                     "unit" => detail.dUnit,
                                                     "RoomNumber" => detail.RoomNumber,
                                                     "title" => detail.title,
                                                     "prereq" => detail.prereq,
                                                     "coreq" => detail.coreq,
                                                     "requiredtext" => detail.requiredtext,
                                                     "description" => detail.coursedetails)
                    @creating_new_course.save

               

                  else if (detail.sectioncode == "SEC" || detail.sectioncode == "STL" || detail.sectioncode == "LAB" || detail.sectioncode == "TUT")
                    creating_new_tutorial = Tutorial.new("tutname" => falculty.dSubject + "-" + section.dSectionNumber,
                                                          "tutcalender" => detail.calender,
                                                          "tutschedule" => detail.DSchedule,
                                                          "tutlocation" => detail.RoomNumber)

                    @creating_new_course.tutorial << creating_new_tutorial
                    creating_new_tutorial.save
                    puts instage_section_url
                    puts detail.DSchedule
                    
                  end



                  detail.delete

                end
                section.delete
            end
          course.delete
          end
        falculty.delete
        end

      end

  end



  def url2015SpringCourses
  
  end



  def urlFalculty(instage_season_url)
    filler_array = []
    source = HTTParty.get(instage_season_url)
    data = JSON.parse((source.body))

    badURL = HTTParty.get(@@base + "ErrorMessage")
    badJSON = JSON.parse((badURL.body))

    if (data == badJSON)
    else
      data.each do |falculty|
        subject = falculty["value"]
        dValue = DFaculty.new("dSubject" => subject)
        dValue.save
        filler_array.push(dValue)
      end
    end

    @AllFalculty = filler_array
  end



  def urlCourse(instage_falculty_url)
    filler_array = []
    source = HTTParty.get(instage_falculty_url)
    data = JSON.parse((source.body))

    badURL = HTTParty.get(@@base + "ErrorMessage")
    badJSON = JSON.parse((badURL.body))

    if (data == badJSON)
    else
      data.each do |course|
        course = course["value"]
        dValue = DCourse.new("dCourseNumber" => course)
        dValue.save
        filler_array.push(dValue)
      end
    end

    @AllCourse = filler_array
  end



  def urlSection(instage_course_url)
    filler_array = []
    source = HTTParty.get(instage_course_url)
    data = JSON.parse((source.body))

    badURL = HTTParty.get(@@base + "ErrorMessage")
    badJSON = JSON.parse((badURL.body))

    if (data == badJSON)
    else
      data.each do |section|
        section = section["value"]
        dValue = DSection.new("dSectionNumber" => section)
        dValue.save
        filler_array.push(dValue)
      end
    end

    @AllSection = filler_array
  end



  def urlDetail(instage_section_url)
    filler_array = []
    source = HTTParty.get(instage_section_url)
    data = JSON.parse((source.body))

    badURL = HTTParty.get(@@base + "ErrorMessage")
    badJSON = JSON.parse((badURL.body))

    if (data == badJSON)
    else

# Professor
      if (data.include?("instructor"))


        professor = data["instructor"]
        professor = professor.first
        professor = professor["name"]
        if (professor == "")
          professor = "Falculty.m"
        end

      else
        professor = "Falculty.m"
      end
###

#Schedule
        overall_schedule = ""
        sectioncode = ""
        roomnumber = ""
        firstRoom = 0

        if(data.include?("courseSchedule"))
        schedule = data["courseSchedule"]
        calender = schedule

            schedule.each do |schedule|
              sectioncode = schedule["sectionCode"]

              if (schedule.include?("startTime"))
                overall_schedule = overall_schedule + schedule["days"] + " " + schedule["startTime"] + " - " + \
                                   schedule["endTime"] + "</br>" + schedule["buildingCode"] + " "+ schedule["roomNumber"] \
                                   + ", " + schedule["campus"] + "</br> </br>"

                
              else
                overall_schedule = "<p> none </p> "
              end


              if (schedule.include?("roomNumber"))
                if (firstRoom == 0)
                  roomnumber = roomnumber + schedule["roomNumber"]
                  firstRoom = 1;
                end

                if (roomnumber.include?(schedule["roomNumber"]))
                else
                  roomnumber = roomnumber + "," + schedule["roomNumber"]
                end

              end



            end

        else
          schedule = "No specific schedule"
        end
###

#CourseTextbook
        requiredtext = ""
        counter = 0
        if(data.include?("requiredText"))
          textbook = data["requiredText"]
          textbook.each do |textbook|
            if counter == 0
              requiredtext = requiredtext + textbook["details"]
              counter = 1
            else
              requiredtext = requiredtext + ", " + textbook["details"]
            end

          end

        end
######






#basic course information
        if(data.include?("info"))
          data = data["info"]
          unit = data["units"]
          designation = data["designation"]
          title = data["title"]

          # if(data.include?("prerequisites"))
          prereq = data["prerequisites"]
          coreq = data["corequisites"]
          coursedetails = data["courseDetails"]




        end
######


        dValue = DDetail.new("title" => title,
                             "prereq" => prereq,
                             "coreq" => coreq, 
                             "requiredtext" => requiredtext,
                             "calender" => calender,
                             "sectioncode" => sectioncode,
                             "dDesignation" => designation,
                             "dUnit" => unit,
                             "dProfessor" => professor,
                             "DSchedule" => overall_schedule,
                             "RoomNumber" => roomnumber,
                             "coursedetails" => coursedetails)
        dValue.save
        filler_array.push(dValue)




    end


    @AllDetail = filler_array

  end




end
