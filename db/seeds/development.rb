# frozen_string_literal: true

# Sample data for local development. Sign in as any of these users through the
# development sign in on the sign in page.
#
# Idempotent: records are looked up by their uid or title and only created when
# missing, so running `bin/rails db:seed` again does not duplicate them.

users = {
  admin: { name: "Annuska Aartsen", username: "annuska.aartsen", role: :admin },
  editor: { name: "Sandford Anson", username: "sandford.anson", role: :editor },
  coordinator: { name: "Clara Okafor", username: "clara.okafor", role: :user },
  member: { name: "Mats Lindqvist", username: "mats.lindqvist", role: :user },
  jonas: { name: "Jonas Weber", username: "jonas.weber", role: :editor },
  lena: { name: "Lena Hoffmann", username: "lena.hoffmann", role: :user },
  sofia: { name: "Sofia Marín", username: "sofia.marin", role: :user },
  finn: { name: "Finn Gallagher", username: "finn.gallagher", role: :user },
  tomas: { name: "Tomás Rivera", username: "tomas.rivera", role: :user },
  rafael: { name: "Rafael Costa", username: "rafael.costa", role: :user }
}.transform_values do |attributes|
  User.find_or_create_by!(provider: "developer", uid: attributes[:username]) do |user|
    user.assign_attributes(attributes)
    user.email = "#{attributes[:username]}@example.com"
    user.avatar_url = "/seeds/avatars/#{attributes[:username]}.jpg"
    user.password = Devise.friendly_token[0, 20]
  end
end

# Uploads an image from db/seeds/images and returns the rich text attachment
# that embeds it, see db/seeds/images/SOURCES.md for the photo credits.
image_attachment = lambda do |name, caption|
  blob = ActiveStorage::Blob.create_and_upload!(
    io: Rails.root.join("db/seeds/images/#{name}.jpg").open,
    filename: "#{name}.jpg",
    content_type: "image/jpeg"
  )
  %(<action-text-attachment sgid="#{blob.attachable_sgid}" content-type="image/jpeg" ) +
    %(caption="#{ERB::Util.html_escape(caption)}"></action-text-attachment>)
end

# Prepends the optional image to the HTML description and removes the
# whitespace between tags, like the rich text editor does.
description = lambda do |attributes|
  html = attributes[:description].gsub(/>\s+</, "><").strip
  [ (image_attachment.call(*attributes[:image]) if attributes[:image]), html ].compact.join
end

projects = [
  {
    title: "Community Bike Workshop",
    image: [ "wheel-truing", "Truing a wheel takes patience. And a spoke wrench." ],
    description: <<~HTML,
      <p>Every Tuesday and Thursday from 6 pm, the doors of our basement workshop on campus are open. Bring your bike, we bring the tools, the know-how and the coffee.</p>
      <h2>What we do</h2>
      <ul>
        <li>Help you fix your own bike, instead of fixing it for you</li>
        <li>Share tools, spare parts and the occasional greasy fingerprint</li>
        <li>Teach the basics: flat tires, brakes and gears</li>
      </ul>
      <blockquote>Nobody leaves with a squeaky chain.</blockquote>
    HTML
    coordinators: [ users[:coordinator] ],
    published: true,
    tasks: [
      {
        title: "Host an evening shift",
        description: <<~HTML,
          <p>Unlock the workshop, put the kettle on and welcome whoever shows up. You don't need to be a pro. Knowing where the tire levers live is enough.</p>
          <ul>
            <li><strong>When:</strong> Tuesday or Thursday, 6 to 9 pm</li>
            <li><strong>Effort:</strong> one evening a month</li>
          </ul>
        HTML
        published: true
      },
      {
        title: "Sort the spare parts",
        description: <<~HTML,
          <p>The donation box has turned into a <em>donation mountain</em>. Help us sort brake pads, tubes and mystery bolts into the labeled drawers.</p>
          <p>Bonus points for finding out what the mystery bolts belong to.</p>
        HTML
        published: true
      },
      {
        title: "Teach a flat tire crash course",
        description: <<~HTML,
          <p>A 30 minute hands-on session for beginners. We provide the tubes and patches, you provide the patience.</p>
          <ol>
            <li>Take the wheel off</li>
            <li>Find and patch the hole</li>
            <li>Put it back on and pump it up</li>
          </ol>
        HTML
        published: true
      },
      {
        title: "Repair the work stands",
        image: [ "work-stand", "The stand on the right has seen better days." ],
        description: <<~HTML,
          <p>Two of our work stands wobble like jelly. Replace the clamps and tighten everything that can be tightened.</p>
        HTML
        published: false
      }
    ]
  },
  {
    title: "Summer Bike Tour",
    image: [ "river-path", "Last year's tour, shortly before the ice cream stop." ],
    description: <<~HTML,
      <p>Once a year we leave the campus behind and ride along the Rhine to <strong>Remagen</strong> and back. About 40 km, flat, with a long lunch break and an optional swim.</p>
      <h2>Who can join</h2>
      <p>Everyone with a roadworthy bike. Kids in trailers and on tandems are very welcome.</p>
    HTML
    coordinators: [ users[:editor], users[:coordinator] ],
    published: true,
    tasks: [
      {
        title: "Plan the route",
        description: <<~HTML,
          <p>Find a family-friendly route of about 40 km with a lunch stop, toilets and as few cobblestones as possible.</p>
          <ul>
            <li>Test ride it once</li>
            <li>Share it as a GPX file</li>
          </ul>
        HTML
        published: true
      },
      {
        title: "Organize the picnic",
        image: [ "drinks-cart", "Our drinks logistics, ideally." ],
        description: <<~HTML,
          <p>Coordinate who brings what for the lunch break. Last year we had eleven pasta salads and no bread. Let's not do that again.</p>
        HTML
        published: true
      },
      {
        title: "Ride as the sweeper",
        description: <<~HTML,
          <p>Ride at the back of the group, make sure nobody gets lost and help with flat tires along the way. We provide a small repair kit and a high-visibility vest.</p>
        HTML
        published: true
      }
    ]
  },
  {
    title: "Cargo Bike Sharing",
    image: [ "cargo-bike-dog", "Bertha on her way to the vet. The passenger was not amused." ],
    description: <<~HTML,
      <p>Our two cargo bikes, <strong>Bertha</strong> and <strong>Kurt</strong>, can be borrowed for free by anyone on campus. Move a sofa, take the kids to the lake or bring your dog to the vet in style.</p>
      <h2>How it works</h2>
      <ol>
        <li>Book a slot in the calendar</li>
        <li>Pick up the key at the workshop</li>
        <li>Bring the bike back clean and charged</li>
      </ol>
    HTML
    coordinators: [ users[:jonas] ],
    published: true,
    tasks: [
      {
        title: "Do the monthly check-up",
        image: [ "cargo-bike-parked", "Kurt, waiting patiently for his check-up." ],
        description: <<~HTML,
          <p>Once a month, check the brakes, tires, lights and child seat belts of Bertha and Kurt. Takes about an hour per bike.</p>
        HTML
        published: true
      },
      {
        title: "Be the key keeper",
        description: <<~HTML,
          <p>Keep the keys for a week. Hand them out, explain the bike in five minutes and check it when it comes back.</p>
        HTML
        published: true
      },
      {
        title: "Find a third cargo bike",
        description: <<~HTML,
          <p>Research grants and second-hand offers. Kurt is getting lonely and Bertha is getting tired.</p>
        HTML
        published: false
      }
    ]
  },
  {
    title: "Light Up the Night",
    image: [ "night-rider", "Seen from a mile away. That's the goal." ],
    description: <<~HTML,
      <p>When the days get shorter, half of the campus rides in the dark. Every November we set up a free light check in front of the cafeteria and fix what we can on the spot.</p>
      <ul>
        <li>Free LED lights for the first 100 riders</li>
        <li>Reflector stickers for everyone</li>
      </ul>
    HTML
    coordinators: [ users[:sofia], users[:jonas] ],
    published: true,
    tasks: [
      {
        title: "Run the light check stand",
        image: [ "night-traffic", "Red is a great color for rear lights. Less so for traffic lights." ],
        description: <<~HTML,
          <p>Check lights and reflectors, swap batteries and mount new lights. A shift is two hours long.</p>
          <ul>
            <li><strong>Date:</strong> first week of November</li>
            <li><strong>Place:</strong> in front of the cafeteria</li>
          </ul>
        HTML
        published: true
      },
      {
        title: "Order lights and batteries",
        description: <<~HTML,
          <p>Compare offers and order 100 sets of front and rear lights within the budget. Ask the student union whether they want to chip in.</p>
        HTML
        published: true
      },
      {
        title: "Design the flyer",
        description: <<~HTML,
          <p>A single page flyer, ideally funny and definitely readable from a moving bike.</p>
        HTML
        published: true
      }
    ]
  },
  {
    title: "Kidical Mass",
    image: [ "family-ride", "The bike lane belongs to the kids today." ],
    description: <<~HTML,
      <p>A colorful bike ride for kids and their families through the city, so the youngest riders can take over the streets for an afternoon.</p>
      <blockquote>Safe streets for kids are safe streets for everyone.</blockquote>
      <p>The ride is about 8 km long, slow and escorted by the police.</p>
    HTML
    coordinators: [ users[:coordinator], users[:finn] ],
    published: true,
    tasks: [
      {
        title: "Marshal the ride",
        image: [ "kid-on-bike", "Our youngest rider of the last ride. Still grinning." ],
        description: <<~HTML,
          <p>Put on a vest, block side streets at junctions and cheer for every kid who rides by. There is a short briefing before the start.</p>
        HTML
        published: true
      },
      {
        title: "Decorate the bikes",
        description: <<~HTML,
          <p>Set up a decoration station with ribbons, balloons and pool noodles. Glitter is allowed, but only a little.</p>
        HTML
        published: true
      },
      {
        title: "Register the ride with the city",
        description: <<~HTML,
          <p>Submit the registration to the public order office at least six weeks ahead and stay in touch with the police.</p>
        HTML
        published: true
      }
    ]
  },
  {
    title: "Second Life Bikes",
    image: [ "rusty-bike", "Before. We'll spare you the after, it's just a bike." ],
    description: <<~HTML,
      <p>Every semester, dozens of bikes are left behind at the campus racks. Together with the university, we collect them, fix them up and give them to students and refugees who need one.</p>
      <h2>So far</h2>
      <ul>
        <li><strong>Winter 2025/26:</strong> 34 bikes given away</li>
        <li><strong>Summer 2026:</strong> 41 bikes given away</li>
      </ul>
    HTML
    coordinators: [ users[:editor], users[:tomas] ],
    published: true,
    tasks: [
      {
        title: "Collect abandoned bikes",
        description: <<~HTML,
          <p>Join the facility team for a morning, cut the locks of the tagged bikes and roll them over to the workshop.</p>
        HTML
        published: true
      },
      {
        title: "Fix up a bike",
        image: [ "pink-kids-bike", "Ready for a new owner, training wheels included." ],
        description: <<~HTML,
          <p>Pick a bike from the backlog and make it roadworthy. The checklist hangs in the workshop and the spare parts are on us.</p>
        HTML
        published: true
      },
      {
        title: "Match bikes with new owners",
        description: <<~HTML,
          <p>Keep the waiting list, arrange the handovers and take a happy photo for the newsletter.</p>
        HTML
        published: true
      }
    ]
  },
  {
    title: "Sunday Beginner Rides",
    image: [ "two-riders", "Matching helmets are optional." ],
    description: <<~HTML,
      <p>Relaxed 20 km rides every other Sunday for everyone who wants to feel more confident in traffic. No lycra required.</p>
    HTML
    coordinators: [ users[:lena] ],
    published: true,
    tasks: [
      {
        title: "Lead a ride",
        description: <<~HTML,
          <p>Pick a route, set a comfortable pace and stop for coffee halfway. You should know the local traffic rules and enjoy explaining them.</p>
        HTML
        published: true
      },
      {
        title: "Write a traffic tips sheet",
        description: <<~HTML,
          <p>Five tips for riding in city traffic, on a single page. For example: <em>Ride a door's width away from parked cars.</em></p>
        HTML
        published: true
      }
    ]
  },
  {
    title: "New Member Onboarding",
    description: <<~HTML,
      <p>A welcome guide and a mentoring program, so new members find their way around the workshop and the collective.</p>
      <p><em>Draft, not published yet.</em></p>
    HTML
    coordinators: [ users[:admin] ],
    published: false,
    tasks: [
      {
        title: "Write the welcome guide",
        description: <<~HTML,
          <p>Summarize on a single page how the collective works: opening hours, who to ask and where the good wrench is hidden.</p>
        HTML
        published: false
      },
      {
        title: "Find mentors",
        description: <<~HTML,
          <p>Find five experienced members who are happy to show a new member around during their first month.</p>
        HTML
        published: false
      }
    ]
  }
]

projects.each do |attributes|
  project = Project.find_or_create_by!(title: attributes[:title]) do |record|
    record.description = description.call(attributes)
    record.coordinators = attributes[:coordinators]
    record.published_at = Time.current if attributes[:published]
  end

  attributes[:tasks].each do |task_attributes|
    project.tasks.find_or_create_by!(title: task_attributes[:title]) do |task|
      task.description = description.call(task_attributes)
      task.coordinators = project.coordinators
      task.published_at = Time.current if task_attributes[:published]
    end
  end
end

[
  { user: :member, task: "Host an evening shift", status: :received, comment: "I can do Tuesdays." },
  { user: :member, task: "Plan the route", status: :accepted, comment: "I know the river path well." },
  { user: :member, task: "Fix up a bike", status: :received, comment: "" },
  { user: :editor, task: "Sort the spare parts", status: :under_review, comment: "" },
  { user: :jonas, task: "Decorate the bikes", status: :interviewing, comment: "I have a box of pool noodles." },
  { user: :lena, task: "Organize the picnic", status: :received, comment: "I'll bring a cake." },
  { user: :sofia, task: "Run the light check stand", status: :accepted, comment: "" },
  { user: :finn, task: "Host an evening shift", status: :interviewing, comment: "Fridays work best for me." },
  { user: :tomas, task: "Sort the spare parts", status: :received, comment: "" },
  { user: :rafael, task: "Plan the route", status: :on_hold, comment: "Happy to test ride it." },
  { user: :rafael, task: "Lead a ride", status: :received, comment: "I know a great bakery on the way." }
].each do |attributes|
  TaskApplication.find_or_create_by!(user: users[attributes[:user]],
                                     task: Task.find_by!(title: attributes[:task])) do |application|
    application.status = attributes[:status]
    application.comment = attributes[:comment]
  end
end

# Branding and footer, only set when missing to keep changes made in the admin.
{
  "brand_name" => -> { Setting.brand_name = "Campus Bike Collective" },
  "display_brand_name" => -> { Setting.display_brand_name = true },
  "brand_logo" => lambda do
    Setting.save_brand_logo(io: Rails.root.join("db/seeds/images/brand-logo.png").open,
                            filename: "brand-logo.png",
                            content_type: "image/png")
  end,
  "footer_copyright" => -> { Setting.footer_copyright = "© #{Date.current.year} Campus Bike Collective e.V." },
  "footer_sitemap" => lambda do
    Setting.footer_sitemap = {
      "categories" => [
        {
          "title" => "Collective",
          "links" => [
            { "title" => "Initiatives", "href" => "/projects" },
            { "title" => "Tasks", "href" => "/tasks" },
            { "title" => "About us", "href" => "https://example.org/about" }
          ]
        },
        {
          "title" => "Community",
          "links" => [
            { "title" => "Chat", "href" => "https://chat.example.org" },
            { "title" => "Newsletter", "href" => "https://example.org/newsletter" },
            { "title" => "Mastodon", "href" => "https://social.example.org/@bikecollective" }
          ]
        }
      ]
    }
  end
}.each do |key, seed|
  seed.call unless Setting.exists?(key: key)
end

# Sample legal pages of a fictional association, not legal advice.
{
  "imprint" => <<~HTML,
    <h1>Imprint</h1>
    <p><strong>Campus Bike Collective e.V.</strong><br>Musterstraße 1<br>12345 Musterstadt<br>Germany</p>
    <h2>Contact</h2>
    <ul>
      <li><strong>Email:</strong> hello@example.org</li>
      <li><strong>Phone:</strong> +49 123 456789</li>
    </ul>
    <h2>Board</h2>
    <p>Annuska Aartsen (chair), Sandford Anson (treasurer)</p>
    <h2>Register</h2>
    <p>Registered in the register of associations of the district court of Musterstadt, VR 12345.</p>
  HTML
  "privacy-policy" => <<~HTML,
    <h1>Privacy Policy</h1>
    <p>We take your privacy seriously and only process the data we need to run this platform.</p>
    <h2>What we store</h2>
    <ul>
      <li>Your name, username, email address and avatar from your chat account</li>
      <li>The tasks you apply for and the messages you send with your application</li>
      <li>Technical logs, which we delete after 14 days</li>
    </ul>
    <h2>Why we store it</h2>
    <p>To connect you with the coordinators of the tasks you are interested in. We never sell your data or use it for advertising.</p>
    <h2>Your rights</h2>
    <p>You can request access to, correction or deletion of your data at any time. Write to <a href="mailto:privacy@example.org">privacy@example.org</a>.</p>
  HTML
  "terms-of-service" => <<~HTML
    <h1>Terms of Service</h1>
    <p>This platform is run by volunteers for volunteers. By using it, you agree to the following terms.</p>
    <ol>
      <li>Be kind to each other. Harassment of any kind is not tolerated.</li>
      <li>Only apply for tasks you intend to take on, and withdraw in time if your plans change.</li>
      <li>Volunteering is unpaid and at your own risk. Wear a helmet.</li>
      <li>We may remove content or accounts that violate these terms.</li>
    </ol>
    <blockquote>Questions? Ask us in the chat, we don't bite.</blockquote>
  HTML
}.each do |slug, content|
  Page.find_or_create_by!(slug: slug) do |page|
    page.content = content.gsub(/>\s+</, "><").strip
  end
end
