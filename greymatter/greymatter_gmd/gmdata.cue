package greymatter_gmd

import (
	gsl "greymatter.io/gsl/v1"

	"greymatter_gmd.module/greymatter:globals"
)

gmdata: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: gmdata.#NewContext & globals

	// name must follow the pattern namespace/name
	name:              "gmdata"
	display_name:      "gmdata"
	version:           "v1.0.0"
	description:       "A data service for greymatter"
	api_endpoint:      "http://\(context.globals.edge_host)/services/\(context.globals.namespace)/\(name)/"
	api_spec_endpoint: "http://\(context.globals.edge_host)/services/\(context.globals.namespace)/\(name)/"
	business_impact:   "low"
	owner:             "greymatter"
	capability:        "gmdata"
	health_options: {
		// spire: gsl.#SpireUpstream & {
		// 	#context: context.SpireContext
		// 	#subjects: ["greymatter-datastore"]
		// }
	}
	// upgrades: "websocket"
	// jupyterlab -> ingress to your container
	ingress: {
		(name): {
			gsl.#HTTPListener
			// gsl.#SpireListener & {
			// 	#context: context.SpireContext
			// 	#subjects: ["team-b-edge"]
			// }

			routes: {
				"/": {
					upstreams: {
						"local": {

							instances: [
								{
									host: "127.0.0.1"
									port: 8181
								},
							]
						}
					}
				}
			}
		}
	}

	// Edge config for the gmdata service.
	// These configs are REQUIRED for your service to be accessible
	// outside your cluster/mesh.
	edge: {
		edge_name: "edge"
		_path:     "/services/\(context.globals.namespace)/\(name)"
		routes: (_path): {
			upstreams: (name): {
				namespace: context.globals.namespace
				gsl.#SpireUpstream & {
					#context: {
						globals.globals
						service_name: "edge"
					}
					#subjects: ["gmdata"]
				}
			}
		}
	}

}

exports: "gmdata": gmdata
