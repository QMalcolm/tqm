# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tqm.Repo.insert!(%Tqm.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Tqm.Repo
alias Tqm.Jobs.Job
alias Tqm.Jobs.Role

## dbt Labs job
job =
  %Job{
    company_name: "dbt Labs",
    url: "https://www.getdbt.com/",
    logo: "images/dbt-logo.png",
    work_description: "TBD"
  }
  |> Repo.insert!()

%Role{
  title: "Software Engineer",
  start_date: ~D[2023-02-16],
  end_date: nil,
  job_id: job.id
}
|> Repo.insert!()

## Transform Data job
job =
  %Job{
    company_name: "Transform Data",
    url: "https://transform.co/",
    logo: "images/transform-logo.png",
    work_description: """
    Many many things, details coming soon!
    """
  }
  |> Repo.insert!()

%Role{
  title: "Software Engineer",
  start_date: ~D[2021-10-04],
  end_date: ~D[2023-02-16],
  job_id: job.id
}
|> Repo.insert!()

## Tyler Technologies job
job =
  %Job{
    company_name: "Tyler Technologies D&I",
    url: "https://www.tylertech.com/solutions/transformative-technology/data-insights",
    logo: "images/tyler-technologies-logo.jpg",
    work_description: """
    Tyler Technologies (Data & Insights Division) makes government data more accessible to the public and makes it easier for government agencies to share information with one another.

    - Wrote frontend architectural specifications for creating white-label customer applications
    - Developed a campaign finance application to address at risk customers representing approx. $23 million potential churn
      - Example: https://data.wa.gov/campaign_finance/
    - Developed system for quickly building new visualizations with Plotly
    - Improved tooling for debugging an internal Elixir Microservice
    - Wrote organizational Elixir best practices documentation
    - Led team through MBI 4 of Site Analytics service and platform NodeJS Upgrade
    - Mentored junior engineers through consistent pairing-programming and check-ins
    - Led the effort to convert common UI components to Typescript
    - Added new ways of ingressing data via the Elixir based dataset management API
    - Constructed customer onsite agents for automatic continuous ingress of datasets
    - Led upgrade of python services from Python 2 to Python 3
    - Organized monthly technical talk series for knowledge sharing across product development teams
    - Organized monthly mixology classes build community
    - Participated in 24/7 oncall by ensuring platform stability in 2 week shifts twice a year and improving emergency documenta
    """
  }
  |> Repo.insert!()

%Role{
  title: "Senior Software Engineer",
  start_date: ~D[2020-03-01],
  end_date: ~D[2021-08-27],
  job_id: job.id
}
|> Repo.insert!()

%Role{
  title: "Software Engineer",
  start_date: ~D[2018-09-17],
  end_date: ~D[2020-02-29],
  job_id: job.id
}
|> Repo.insert!()

## Roll For Guild job
job =
  %Job{
    company_name: "Roll For Guild",
    url: "",
    logo: "images/roll-for-guild-logo.jpg",
    work_description: """
    Roll For Guild built tools for organizing and running Tabletop Role-Playing Games

    - Composed backbone AWS infrastructure
    - Wrote specifications for Elixir based API (users, groups, auth, event management, notifications, geosearch)
    - Led small distributed team in development of the Elixir based multi-platform API
    - Handled operational issues such as filing articles of incorporation, corporate bank account, general marketing, and etc.
    """
  }
  |> Repo.insert!()

%Role{
  title: "Founder, CEO, Backend Developer",
  start_date: ~D[2017-10-04],
  end_date: ~D[2020-09-16],
  job_id: job.id
}
|> Repo.insert!()

## Kilter Rewards job
job =
  %Job{
    company_name: "Kilter Rewards",
    url: "https://www.kilterrewards.com/",
    logo: "images/kilter-rewards-logo.png",
    work_description: """
    Kilter rewarded people for working out

    - Wrote specifications for and led development of Golang Mobile API (points system, workout check ins, partnered business rewards, monitoring)
    - Implemented Geofencing system for tracking gym based workouts
    - Migrated API, Database, and Frontend to AWS based infrastructure
    - Led normalization of data schema in MariaDB
    - Built a CLI enabling support staff to handle customer tickets with less engineering intervention
    - Worked with mobile team on prototyping app UX/UI designs
    """
  }
  |> Repo.insert!()

%Role{
  title: "Technical Co-Founder",
  start_date: ~D[2017-09-01],
  end_date: ~D[2018-04-30],
  job_id: job.id
}
|> Repo.insert!()

%Role{
  title: "Lead Backend Developer",
  start_date: ~D[2017-05-04],
  end_date: ~D[2017-09-01],
  job_id: job.id
}
|> Repo.insert!()

## SSEC Job
job =
  %Job{
    company_name: "SSEC UW Madison",
    url: "https://www.ssec.wisc.edu/",
    logo: "images/ssec-logo.png",
    work_description: """
    - Wrote specifications for and built a smart scaling ETL pipeline utilizing Python, Cron, and RabbitMQ for processing weather satellite image metadata
    - Built a Python API and Angular dashboard for monitoring the ETL pipeline
    - Developed CLI tooling for management of ETL pipeline
    - Wrote Emergency Playbooks downtime scenarios
    """
  }
  |> Repo.insert!()

%Role{
  title: "Student Developer",
  start_date: ~D[2016-07-01],
  end_date: ~D[2017-05-31],
  job_id: job.id
}
|> Repo.insert!()

## Catalyze.io Job
job =
  %Job{
    company_name: "Catalyze.io",
    url: "https://web.archive.org/web/20161221193246/https://catalyze.io/",
    logo: "images/catalyze-logo.png",
    work_description: """
    Catalyze.io enabled organizations to host applications in a HIPAA compliant environment

    - Developed customer facing web tools for managing applications in HIPAA environments
    - Worked directly with Veterans Affairs for integration of logging service with their Mindfulness App
    - Built a system for customers which dynamically generated dashboards for monitoring their environments
    """
  }
  |> Repo.insert!()

%Role{
  title: "Software Enginering Intern",
  start_date: ~D[2015-05-15],
  end_date: ~D[2016-05-14],
  job_id: job.id
}
|> Repo.insert!()

## Wests Hayward Dairy Job
job =
  %Job{
    company_name: "West's Hayward Dairy",
    url: "http://westsdairy.com/",
    logo: "images/wests-dairy-logo.png",
    work_description: ""
  }
  |> Repo.insert!()

%Role{
  title: "Head Ice Cream Maker",
  start_date: ~D[2013-05-01],
  end_date: ~D[2015-05-31],
  job_id: job.id
}
|> Repo.insert!()

%Role{
  title: "Small Batch Ice Cream Maker",
  start_date: ~D[2009-05-01],
  end_date: ~D[2013-05-01],
  job_id: job.id
}
|> Repo.insert!()

%Role{
  title: "Front Staff",
  start_date: ~D[2008-05-01],
  end_date: ~D[2013-05-01],
  job_id: job.id
}
|> Repo.insert!()
