--- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.ai_sugerencias (
  sugerencia_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  solicitud_id bigint NOT NULL,
  categoria_id bigint,
  servicio_id bigint,
  nombre_sugerido character varying,
  nota character varying,
  tipo character varying,
  confianza numeric DEFAULT NULL::numeric,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ai_sugerencias_pkey PRIMARY KEY (sugerencia_id),
  CONSTRAINT fk_ai_sug_solicitud FOREIGN KEY (solicitud_id) REFERENCES public.solicitudes_texto(solicitud_id),
  CONSTRAINT fk_ai_sug_categoria FOREIGN KEY (categoria_id) REFERENCES public.categorias_servicio(categoria_id),
  CONSTRAINT fk_ai_sug_servicio FOREIGN KEY (servicio_id) REFERENCES public.servicios(servicio_id)
);
CREATE TABLE public.cancelaciones (
  cancelacion_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  evento_id bigint NOT NULL,
  quien character varying NOT NULL,
  motivo text,
  politica character varying NOT NULL,
  porcentaje_penalidad numeric NOT NULL,
  porcentaje_plataforma numeric NOT NULL,
  penalidad_proveedor numeric NOT NULL DEFAULT 0.00,
  penalidad_cliente numeric NOT NULL DEFAULT 0.00,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT cancelaciones_pkey PRIMARY KEY (cancelacion_id),
  CONSTRAINT fk_cancelaciones_evento FOREIGN KEY (evento_id) REFERENCES public.eventos(evento_id)
);
CREATE TABLE public.cancelaciones_evento (
  cancelacion_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  evento_id bigint NOT NULL UNIQUE,
  user_id uuid NOT NULL,
  motivo_cancelacion text NOT NULL,
  penalizacion_porcentaje numeric NOT NULL DEFAULT 0.00,
  monto_devolver numeric NOT NULL,
  reembolso_id bigint,
  fecha_cancelacion timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT cancelaciones_evento_pkey PRIMARY KEY (cancelacion_id),
  CONSTRAINT fk_ce_evento FOREIGN KEY (evento_id) REFERENCES public.eventos(evento_id),
  CONSTRAINT fk_ce_user FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT fk_ce_reembolso FOREIGN KEY (reembolso_id) REFERENCES public.reembolsos(reembolso_id)
);
CREATE TABLE public.categorias_servicio (
  categoria_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying NOT NULL UNIQUE,
  descripcion text,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT categorias_servicio_pkey PRIMARY KEY (categoria_id)
);
CREATE TABLE public.clientes (
  user_id uuid NOT NULL,
  full_name text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT clientes_pkey PRIMARY KEY (user_id),
  CONSTRAINT clientes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.cotizacion_items (
  item_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  cotizacion_id bigint NOT NULL,
  servicio_id bigint,
  proveedor_id uuid,
  cantidad integer NOT NULL DEFAULT 1,
  precio_unitario numeric DEFAULT NULL::numeric,
  subtotal numeric DEFAULT ((COALESCE(cantidad, 0))::numeric * COALESCE(precio_unitario, (0)::numeric)),
  notas character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT cotizacion_items_pkey PRIMARY KEY (item_id),
  CONSTRAINT fk_ci_cotizacion FOREIGN KEY (cotizacion_id) REFERENCES public.cotizaciones(cotizacion_id),
  CONSTRAINT fk_ci_servicio FOREIGN KEY (servicio_id) REFERENCES public.servicios(servicio_id),
  CONSTRAINT fk_ci_proveedor FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(user_id)
);
CREATE TABLE public.cotizacion_logs (
  log_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  cotizacion_id bigint NOT NULL,
  actor_type character varying,
  actor_id uuid,
  detalle jsonb,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT cotizacion_logs_pkey PRIMARY KEY (log_id),
  CONSTRAINT fk_cl_cotizacion FOREIGN KEY (cotizacion_id) REFERENCES public.cotizaciones(cotizacion_id)
);
CREATE TABLE public.cotizacion_proveedores (
  cp_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  cotizacion_id bigint NOT NULL,
  proveedor_id uuid NOT NULL,
  estado character varying NOT NULL DEFAULT 'enviado'::character varying,
  fecha_notificacion timestamp with time zone NOT NULL DEFAULT now(),
  fecha_respuesta timestamp with time zone,
  CONSTRAINT cotizacion_proveedores_pkey PRIMARY KEY (cp_id),
  CONSTRAINT fk_cp_cotizacion FOREIGN KEY (cotizacion_id) REFERENCES public.cotizaciones(cotizacion_id),
  CONSTRAINT fk_cp_proveedor FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(user_id)
);
CREATE TABLE public.cotizaciones (
  cotizacion_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  solicitud_id bigint,
  titulo character varying,
  descripcion text,
  total_estimado numeric DEFAULT NULL::numeric,
  estado character varying NOT NULL DEFAULT 'borrador'::character varying,
  validez_dias integer NOT NULL DEFAULT 7,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT cotizaciones_pkey PRIMARY KEY (cotizacion_id),
  CONSTRAINT fk_cot_user FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT fk_cot_solicitud FOREIGN KEY (solicitud_id) REFERENCES public.solicitudes_texto(solicitud_id)
);
CREATE TABLE public.detalle_servicio_evento (
  detalle_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  evento_id bigint NOT NULL,
  servicio_id bigint NOT NULL,
  proveedor_id uuid NOT NULL,
  cantidad integer NOT NULL DEFAULT 1,
  precio_unitario numeric NOT NULL,
  subtotal numeric DEFAULT ((cantidad)::numeric * precio_unitario),
  fecha_servicio date,
  hora_inicio time without time zone,
  hora_fin time without time zone,
  notas_especificas character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT detalle_servicio_evento_pkey PRIMARY KEY (detalle_id),
  CONSTRAINT fk_dse_evento FOREIGN KEY (evento_id) REFERENCES public.eventos(evento_id),
  CONSTRAINT fk_dse_servicio FOREIGN KEY (servicio_id) REFERENCES public.servicios(servicio_id),
  CONSTRAINT fk_dse_proveedor FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(user_id)
);
CREATE TABLE public.evento_servicios (
  ev_serv_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  evento_id bigint NOT NULL,
  servicio_id bigint NOT NULL,
  proveedor_id uuid NOT NULL,
  cantidad integer NOT NULL,
  precio_unitario numeric NOT NULL,
  subtotal numeric DEFAULT ((cantidad)::numeric * precio_unitario),
  fecha_servicio date NOT NULL,
  hora_llegada time without time zone,
  hora_inicio_servicio time without time zone NOT NULL,
  hora_fin_servicio time without time zone NOT NULL,
  minutos_montaje integer,
  minutos_desmontaje integer,
  notas_cliente character varying,
  notas_proveedor character varying,
  estado character varying NOT NULL DEFAULT 'propuesto'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT evento_servicios_pkey PRIMARY KEY (ev_serv_id),
  CONSTRAINT fk_es_evento FOREIGN KEY (evento_id) REFERENCES public.eventos(evento_id),
  CONSTRAINT fk_es_servicio FOREIGN KEY (servicio_id) REFERENCES public.servicios(servicio_id),
  CONSTRAINT fk_es_proveedor FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(user_id)
);
CREATE TABLE public.eventos (
  evento_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  cliente_id uuid NOT NULL,
  titulo character varying NOT NULL,
  fecha_evento date NOT NULL,
  hora_inicio time without time zone NOT NULL,
  hora_fin time without time zone,
  direccion_texto character varying NOT NULL,
  latitud numeric,
  longitud numeric,
  estado_evento character varying NOT NULL DEFAULT 'borrador'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT eventos_pkey PRIMARY KEY (evento_id),
  CONSTRAINT fk_eventos_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(user_id)
);
CREATE TABLE public.incidentes (
  incidente_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  evento_id bigint NOT NULL,
  user_id uuid,
  reportado_por character varying NOT NULL,
  severidad character varying NOT NULL,
  descripcion text NOT NULL,
  estado_caso character varying NOT NULL DEFAULT 'abierto'::character varying,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT incidentes_pkey PRIMARY KEY (incidente_id),
  CONSTRAINT fk_incidente_evento FOREIGN KEY (evento_id) REFERENCES public.eventos(evento_id),
  CONSTRAINT fk_incidente_user FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.mensajes (
  mensaje_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  evento_id bigint NOT NULL,
  emisor_id uuid NOT NULL,
  receptor_id uuid NOT NULL,
  contenido text NOT NULL,
  tipo_contenido character varying NOT NULL DEFAULT 'texto'::character varying,
  leido boolean NOT NULL DEFAULT false,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT mensajes_pkey PRIMARY KEY (mensaje_id),
  CONSTRAINT fk_mensajes_evento FOREIGN KEY (evento_id) REFERENCES public.eventos(evento_id),
  CONSTRAINT fk_mensajes_emisor FOREIGN KEY (emisor_id) REFERENCES auth.users(id),
  CONSTRAINT fk_mensajes_receptor FOREIGN KEY (receptor_id) REFERENCES auth.users(id)
);
CREATE TABLE public.metodos_pago (
  metodo_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying NOT NULL,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT metodos_pago_pkey PRIMARY KEY (metodo_id)
);
CREATE TABLE public.notificaciones (
  notificacion_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  titulo character varying NOT NULL,
  mensaje character varying NOT NULL,
  tipo_notif character varying NOT NULL,
  leido boolean NOT NULL DEFAULT false,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT notificaciones_pkey PRIMARY KEY (notificacion_id),
  CONSTRAINT fk_notificaciones_user FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.pagos (
  pago_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  evento_id bigint NOT NULL,
  monto_total numeric NOT NULL,
  moneda character NOT NULL DEFAULT 'MXN'::bpchar,
  estado_pago character varying NOT NULL DEFAULT 'pendiente'::character varying,
  referencia_pago character varying,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  metodo_id bigint,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT pagos_pkey PRIMARY KEY (pago_id),
  CONSTRAINT fk_pagos_evento FOREIGN KEY (evento_id) REFERENCES public.eventos(evento_id),
  CONSTRAINT fk_pagos_metodo FOREIGN KEY (metodo_id) REFERENCES public.metodos_pago(metodo_id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  full_name text,
  rol text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.proveedores (
  user_id uuid NOT NULL,
  full_name text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT proveedores_pkey PRIMARY KEY (user_id),
  CONSTRAINT proveedores_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.reembolsos (
  reembolso_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  pago_id bigint NOT NULL,
  monto numeric NOT NULL,
  razon text,
  estado character varying NOT NULL DEFAULT 'solicitado'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT reembolsos_pkey PRIMARY KEY (reembolso_id),
  CONSTRAINT fk_reembolsos_pago FOREIGN KEY (pago_id) REFERENCES public.pagos(pago_id)
);
CREATE TABLE public.reportes (
  reporte_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  tipo_reporte character varying NOT NULL,
  referencia_id character varying,
  descripcion text,
  estado_reporte character varying NOT NULL,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT reportes_pkey PRIMARY KEY (reporte_id),
  CONSTRAINT fk_reportes_user FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.resenas (
  resena_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  evento_id bigint NOT NULL,
  cliente_id uuid NOT NULL,
  ev_serv_id bigint NOT NULL,
  calificacion smallint NOT NULL,
  comentario character varying,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT resenas_pkey PRIMARY KEY (resena_id),
  CONSTRAINT fk_resenas_evento FOREIGN KEY (evento_id) REFERENCES public.eventos(evento_id),
  CONSTRAINT fk_resenas_cliente FOREIGN KEY (cliente_id) REFERENCES public.clientes(user_id),
  CONSTRAINT fk_resenas_ev_serv FOREIGN KEY (ev_serv_id) REFERENCES public.evento_servicios(ev_serv_id)
);
CREATE TABLE public.servicios (
  servicio_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  proveedor_id uuid NOT NULL,
  categoria_id bigint NOT NULL,
  nombre character varying NOT NULL,
  descripcion text,
  precio_base numeric NOT NULL,
  precio_unidad character varying NOT NULL,
  capacidad_min integer,
  capacidad_max integer,
  estado character varying NOT NULL DEFAULT 'activo'::character varying,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT servicios_pkey PRIMARY KEY (servicio_id),
  CONSTRAINT fk_servicios_proveedor FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(user_id),
  CONSTRAINT fk_servicios_categoria FOREIGN KEY (categoria_id) REFERENCES public.categorias_servicio(categoria_id)
);
CREATE TABLE public.solicitudes_texto (
  solicitud_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid,
  texto_original text NOT NULL,
  idioma character varying DEFAULT 'es'::character varying,
  estado character varying DEFAULT 'pendiente_ia'::character varying,
  confianza numeric DEFAULT NULL::numeric,
  ai_response jsonb,
  create_at timestamp with time zone NOT NULL DEFAULT now(),
  update_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT solicitudes_texto_pkey PRIMARY KEY (solicitud_id),
  CONSTRAINT fk_solicitudes_user FOREIGN KEY (user_id) REFERENCES auth.users(id)
);