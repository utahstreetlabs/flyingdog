(load-file "src/flyingdog/version.clj")

(defproject flyingdog flyingdog.version/version
  :description "Copious Auth Service"
  :dependencies [[org.clojure/clojure "1.3.0"]
                 [org.clojure/data.json "0.1.1"]
                 [org.clojure/tools.logging "0.2.3"]
                 [clj-logging-config "1.9.6"]
                 [ring/ring-core "1.1.1"]
                 [ring/ring-jetty-adapter "1.1.1"]
                 [copious/auth "0.3.1-SNAPSHOT"]
                 [compojure "1.1.0"]]
  :plugins [[lein-ring "0.7.1"]]
  :repositories {"snapshots"
                 {:url "" :username "" :password ""}
                 "releases"
                 {:url "" :username "" :password ""}}

  :ring {:handler flyingdog/app :init flyingdog/app-init :port 4070}
  :main flyingdog)
