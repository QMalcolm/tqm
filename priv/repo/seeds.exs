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
    description: """
    [dbt Labs](https://www.getdbt.com/) builds data transformation tools that enable data analysts and engineers to transform, test and document data in the cloud data warehouse.
    """
  }
  |> Repo.insert!()

%Role{
  title: "Software Engineer",
  start_date: ~D[2023-02-16],
  end_date: nil,
  job_id: job.id,
  details: "TBD"
}
|> Repo.insert!()

## Transform Data job
job =
  %Job{
    company_name: "Transform Data",
    url: "https://transform.co/",
    logo: "images/transform-logo.png",
    description: """
    [Transform Data](https://transform.co/) was [acquired in 2023](https://techcrunch.com/2023/02/08/dbt-acquires-transform/) by [dbt Labs](https://www.getdbt.com/).

    Transform Data built a Metrics Store giving orgs the ability to work on the metrics layer in the modern data stack providing consistent data and metrics governance.
    Responsible for the first and most advanced metrics semantic layer (headless BI) [MetricFlow](https://github.com/transform-data/metricflow).
    """
  }
  |> Repo.insert!()

%Role{
  title: "Software Engineer",
  start_date: ~D[2021-10-04],
  end_date: ~D[2023-02-16],
  job_id: job.id,
  details: """
  Details coming soon
  """
}
|> Repo.insert!()

## Tyler Technologies job
job =
  %Job{
    company_name: "Tyler Technologies D&I",
    url: "https://www.tylertech.com/solutions/transformative-technology/data-insights",
    logo: "images/tyler-technologies-logo.jpg",
    description: """
    [Tyler Technologies (Data & Insights Division)](https://www.tylertech.com/solutions/transformative-technology/data-insights) makes government data more accessible to the public and makes it easier for government agencies to share information with one another.
    """
  }
  |> Repo.insert!()

%Role{
  title: "Senior Software Engineer",
  start_date: ~D[2020-03-01],
  end_date: ~D[2021-08-27],
  job_id: job.id,
  details: """
  - Wrote frontend architectural specifications for creating white-label customer applications
  - Developed a campaign finance application to address at risk customers representing approx. $23 million potential churn
    - Example: https://data.wa.gov/campaign_finance/
  - Developed system for quickly building new visualizations with Plotly
  - Improved tooling for debugging an internal Elixir Microservice
  - Wrote organizational Elixir best practices documentation
  - Led team through MBI 4 of Site Analytics service and platform NodeJS Upgrade
  - Mentored junior engineers through consistent pairing-programming and check-ins
  - Continued organization of educational and social events
  - Continued oncall participation
  """
}
|> Repo.insert!()

%Role{
  title: "Software Engineer",
  start_date: ~D[2018-09-17],
  end_date: ~D[2020-02-29],
  job_id: job.id,
  details: """
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

## Roll For Guild job
job =
  %Job{
    company_name: "Roll For Guild",
    url: "https://web.archive.org/web/20180817113913/https://rollforguild.com/",
    logo: "images/roll-for-guild-logo.jpg",
    description: """
    [Roll For Guild](https://web.archive.org/web/20180817113913/https://rollforguild.com/) built tools for organizing and running Tabletop Role-Playing Games
    """
  }
  |> Repo.insert!()

%Role{
  title: "Founder, CEO, Backend Developer",
  start_date: ~D[2017-10-04],
  end_date: ~D[2020-09-16],
  job_id: job.id,
  details: """
  - Composed backbone AWS infrastructure
  - Wrote specifications for Elixir based API (users, groups, auth, event management, notifications, geosearch)
  - Led small distributed team in development of the Elixir based multi-platform API
  - Handled operational issues such as filing articles of incorporation, corporate bank account, general marketing, and etc.
  """
}
|> Repo.insert!()

## Kilter Rewards job
job =
  %Job{
    company_name: "Kilter Rewards",
    url: "https://www.kilterrewards.com/",
    logo: "images/kilter-rewards-logo.png",
    description: """
    [Kilter Rewards](https://www.kilterrewards.com/) was [acquired in 2022](https://www.blackbaud.com/newsroom/article/2022/08/22/blackbaud-acquires-kilter-an-activity-based-engagement-app) by [Blackbaud](https://www.blackbaud.com/).

    [Kilter](https://www.kilterrewards.com/")'s goal was to encourage people to workout.
    Kilter did that by rewarding people with points when they checked in to a gym via the Kilter app and
    allowing those points to be used on rewards currated from local businesses.
    """
  }
  |> Repo.insert!()

%Role{
  title: "Technical Co-Founder and Lead Backend Developer",
  start_date: ~D[2017-05-04],
  end_date: ~D[2018-04-30],
  job_id: job.id,
  details: """
  - Wrote specifications for and led development of Golang Mobile API (points system, workout check ins, partnered business rewards, monitoring)
  - Implemented Geofencing system for tracking gym based workouts
  - Migrated API, Database, and Frontend to AWS based infrastructure
  - Led normalization of data schema in MariaDB
  - Built a CLI enabling support staff to handle customer tickets with less engineering intervention
  - Worked with mobile team on prototyping app UX/UI designs
  """
}
|> Repo.insert!()

## SSEC Job
job =
  %Job{
    company_name: "SSEC UW Madison",
    url: "https://www.ssec.wisc.edu/",
    logo: "images/ssec-logo.png",
    description: """
    The [Space Science and Engineering Center](https://www.ssec.wisc.edu/) (SSEC) of University of Wisconsin Madison
    The Center's research includes studying new instrument technologies, data analysis, visualization, and weather product development.
    My time at the Center was spent designing, building, and supporting an ETL pipeline for weather satellite image metdata enabling
    researchers to better find the data they needed for their research.
    """
  }
  |> Repo.insert!()

%Role{
  title: "Student Developer",
  start_date: ~D[2016-07-01],
  end_date: ~D[2017-05-31],
  details: """
  - Wrote specifications for and built a smart scaling ETL pipeline utilizing Python, Cron, and RabbitMQ for processing weather satellite image metadata
  - Built a Python API and Angular dashboard for monitoring the ETL pipeline
  - Developed CLI tooling for management of ETL pipeline
  - Wrote Emergency Playbooks for the long term support of the system
  """,
  job_id: job.id
}
|> Repo.insert!()

## Catalyze.io Job
job =
  %Job{
    company_name: "Catalyze.io",
    url: "https://web.archive.org/web/20161221193246/https://catalyze.io/",
    logo: "images/catalyze-logo.png",
    description: """
    [Catalyze.io](https://web.archive.org/web/20161221193246/https://catalyze.io/) was [rebranded in 2017](https://web.archive.org/web/20190521185256/https://datica.com/catalyze/) to [Datica](https://web.archive.org/web/20200810203042/https://datica.com/).
    [Datica](https://web.archive.org/web/20200810203042/https://datica.com/) was [acquired in 2021](https://hitconsultant.net/2021/04/27/lyniate-acquires-datica-integration-business/) by [Lyniate](https://lyniate.com/).

    Catalyze.io enabled organizations to host applications in a HIPAA compliant environment and built healthcare integrations.
    """
  }
  |> Repo.insert!()

%Role{
  title: "Software Enginering Intern",
  start_date: ~D[2015-05-15],
  end_date: ~D[2016-05-14],
  job_id: job.id,
  details: """
  - Developed customer facing web tools for managing applications in HIPAA environments
  - Worked directly with Veterans Affairs for integration of logging service with their Mindfulness App
  - Built a system giving customers dynamically generated dashboards for monitoring their environments
  """
}
|> Repo.insert!()

## Wests Hayward Dairy Job
job =
  %Job{
    company_name: "West's Hayward Dairy",
    url: "http://westsdairy.com/",
    logo: "images/wests-dairy-logo.png",
    description: """
    [West's Hayward Dairy]("http://westsdairy.com/") is a ice cream shop in Hayward, WI.
    The Dairy makes all of it's ice cream in house which is not just served in the store front,
    but also sold to local restuarants, and distributed to regional grocery stores. It's an iconic
    part of any trip to Hayward, WI.
    """
  }
  |> Repo.insert!()

%Role{
  title: "Head Ice Cream Maker",
  start_date: ~D[2013-05-01],
  end_date: ~D[2015-05-31],
  job_id: job.id,
  details: """
  - Forecast and organized production schedule
  - Managed and ordered dairy's ingredients
  - Ran continous freezer for production to restuarants and grocery stores
  - Taught apprentices how to safely and effectively run the continous freezer
  - Invented new ice cream flavors
  - Ate a lot of ice cream (in addition to having to taste test every production run)
  """
}
|> Repo.insert!()

%Role{
  title: "Small Batch Ice Cream Maker",
  start_date: ~D[2009-05-01],
  end_date: ~D[2013-05-01],
  job_id: job.id,
  details: """
  - Responsible for organization of all walk-in freezers
  - Assisted the head ice cream maker on the continous freezer
  - Regulary made specialty ice creams on batch freezer
  - Took on teaching others how to run the batch freezer
  - Ate so much ice cream (in addition to having to taste test every batch run)
  """
}
|> Repo.insert!()

%Role{
  title: "Front Staff",
  start_date: ~D[2008-05-01],
  end_date: ~D[2013-05-01],
  job_id: job.id,
  details: """
  - Served so much ice cream
  - Ate so much ice cream
  """
}
|> Repo.insert!()
