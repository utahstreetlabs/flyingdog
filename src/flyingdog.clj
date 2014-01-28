(ns flyingdog
  (:require [clojure.data.json :as json]
            [ring.adapter.jetty :as ring]
            [compojure.core :as cc]
            [compojure.route :as route]
            [compojure.handler :as handler]
            [clojure.string :as string]
            [clojure.tools.logging :as log]
            [clj-logging-config.log4j :as log-config]
            [copious.auth.core :as auth]))

(defn response [status body]
  {:headers {"Content-Type" "application/json; charset=utf-8"}
   :body body
   :status status})

(defn success [body]
  (response 200 body))

(defn json-success [body]
  (success (json/json-str body)))

(defn no-content []
  (response 204 nil))

(defn error [body]
  (response 500 body))

(defn not-found []
  (response 404 nil))

(cc/defroutes identity-routes
  (cc/GET "/:provider/identities/:uid" [provider uid]
    (log/debug "searching for uid:" uid "from provider" provider)
    (if-let [data (auth/fetch provider uid)]
      (json-success data)
      (not-found)))
  (cc/PUT "/:provider/identities/:uid" {params :params body :body}
    (let [data (json/read-json (slurp body))
          args (merge data (select-keys params [:provider :uid]))]
      (log/debug "received:" data)
      (if-let [result (auth/store args)]
        (json-success result)
        (error nil))))
  (cc/DELETE "/:provider/identities/:uid" [provider uid]
    ;; XXX: what to check for?
    (auth/delete provider uid)
    (no-content)))

(cc/defroutes main-routes
  (cc/context "/providers" [] identity-routes)
  (cc/DELETE "/" []
    (auth/delete-all)
    (no-content)))

(def env (keyword (or (System/getenv "FLYINGDOG_ENV") (System/getenv "FD_ENV") "development")))

(defn app-init []
  (auth/set-environment! env)
  (log-config/set-logger! :level :debug :out :console))

(def app
  (handler/site main-routes))

(defn -main []
  (log/info "DEPRECATED: use 'lein ring server'"))
