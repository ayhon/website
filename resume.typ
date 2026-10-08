#import "@preview/modern-cv:0.10.0": *

#show: resume.with(
  author: (
    firstname: "Fernando",
    lastname: "Leal Sánchez",
    email: "f@leal.sh",
    github: "ayhon",
    homepage: "f.leal.sh",
    linkedin: "fileal",
    positions: (),
  ),
  header-font: "IBM Plex Sans SmBld",
  font: ("Inter Display"),
  // font: ("Source Sans 3", "Source Sans Pro"),
  profile-picture: none,
  date: datetime.today().display(),
  language: "en",
  colored-headers: true,
  show-footer: false,
  show-address-icon: true,
  paper-size: "us-letter",
  contact-items-separator: [#h(0.6em)#text("✦", fill: gray)#h(0.6em)]// box[#h(2pt)#text("|")#h(2pt)],
)

#let education = [

= Education

#resume-entry(
  title: "ENS Paris-Saclay",
  location: "Paris, France",
  date: "Sep 2024 - Aug 2026",
  description: "Parisian Master of Research in Computer Science",
)

#resume-entry(
  title: "Universidad Complutense de Madrid",
  location: "Madrid, Spain",
  date: "Sep 2019 - Jun 2024",
  description: "Bacherlor's in Computer Science / Bacherlor's in Mathematics",
  // TODO: Include grades, (8.56) / (8.39) respectively
)

#resume-entry(
  title: "École Polytechnique Fédérale de Lausanne",
  location: "Lausanne, Switzerland",
  date: "Sep 2021 - Jun 2022",
  description: "Erasmus programme",
)

#resume-entry(
  title: "Ironwood Ridge High School",
  location: "Arizona, USA",
  date: "Aug 2016 - May 2017",
  description: "Exchange program",
)
]

#let experience = [

= Experience

#resume-entry(
  title: "PLF, ETH Zurich",
  location: "Zürich, Switzerland",
  date: "Apr 2026 - Sep 2026",
  description: "M2 Research internship",
)

#resume-item[
  - #link("https://github.com/leanprover-community/iris-lean/graphs/contributors?from=12%2F18%2F2025&to=6%2F28%2F2026")[Contribute] to the #link("https://github.com/leanprover-community/iris-lean/pulls?q=is%3Apr+author%3A%40ayhon")[Iris Lean] project
  - Develop #link("https://gitlab.inf.ethz.ch/ou-plf/wander#")[Lean automation] for Iris proofs
]

#resume-entry(
  title: "Prosecco, Inria",
  location: "Paris, France",
  date: "Feb 2025 - Jul 2025",
  description: "M1 Research internship",
)

#resume-item[
  - Develop #link("https://github.com/AeneasVerif/aeneas/pulls?q=is%3Apr+author%3A%40ayhon")[proof automation with Aeneas]
  - Verify #link("https://github.com/ayhon/sha3.lean")[SHA3] #link("https://github.com/ayhon/sha3.rs")[Rust implementation] with Lean
]

#resume-entry(
  title: link("https://bendingspoons.com/", "Bending Spoons"),
  location: "Remote",
  date: "Nov 2023 - Aug 2024",
  description: "Backend software engineer",
)

#resume-item[
  - Development and maintenance of monetization data pipelines
  - Migration of legacy systems
]
]

#let associations = [

= Associations

#resume-entry(
  title: "UCppM",
  location: "Madrid, Spain",
  date: "Sep 2022 - Jun 2024",
  description: "Founder and first president of the competitive programming association",
)

#resume-entry(
  title: "Organizers",
  location: "Lausanne, Switzerland",
  date: "Nov 2021 - Nov 2022",
  description: "CTF Player",
)

#resume-entry(
  title: "2022 ICPC Europe Training Camp",
  location: "Wroclaw, Poland",
  date: "Oct 2022 - Oct 2022",
  description: "Invited participant",
)

#resume-entry(
  title: "World Scout Jamboree",
  location: "West Virginia, USA",
  date: "Jul 2019 - Aug 2019",
  description: "International service team volunteer",
)

]

#let skills = [

= Skills

#resume-skill-item(
  "Programming Languages",
  (
    strong("Lean"),
    strong("Rocq"),
    strong("Python"),
    "Rust",
    "Scala",
    "TypeScript",
    "C++",
    "Haskell",
    "OCaml",
  ),
)

#resume-skill-item("Languages", 
  (strong("Spanish"), strong("English"), "French")
)

#resume-skill-item("Sports",
  (
    strong("Bouldering"),
    strong("Judo"),
    "Wrestling",
    "Handball",
  ),
)
// spacing fix, not needed if you use `resume-skill-grid`
#block(below: 0.65em)

]

// = Awards


#experience
#education
#associations
#skills
