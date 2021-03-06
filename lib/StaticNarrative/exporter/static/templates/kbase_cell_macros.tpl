{%- macro result_tab(metadata, narrative_link) -%}
    {% if metadata.output.report %}
        {% set rep = metadata.output.report %}
        {% if rep.objects|count > 0 %}
            {{ objects_panel(rep.objects, metadata.idx) }}
        {% endif %}
        {% if rep.html.links or rep.html.direct %}
            {{ report_panel(rep.html, metadata.idx) }}
        {% endif %}
        {% if rep.summary %}
            {{ summary_panel(rep.summary, rep.summary_height, metadata.idx) }}
        {% endif %}
        {% if rep.html.links %}
            {{ report_links_panel(rep.html, metadata.idx) }}
        {% endif %}
        {% if rep.html.file_links %}
            {{ report_file_links_panel(rep.html, metadata.idx, narrative_link) }}
        {% endif %}
    {% else %}
        <div class="kb-no-output">No output found.</div>
    {% endif %}
{%- endmacro -%}

{#
 Renders the report panel with embedded report iframe...
 #}
{% macro report_panel(html_info, idx) %}
    {% call render_panel("Report", idx) -%}
        {% if html_info.link_idx is not none and html_info.paths %}
            <div data-kbreport="{{ html_info.paths[html_info.link_idx] }}">
                <a class="btn btn-md btn-default" target="_blank">
                View report in separate window
                </a>
                <div class="kb-app-report"></div>
            </div>
        {% elif html_info.direct %}
            <iframe src="{{ html_info.direct|e }}"
                    class="kb-app-report-iframe"
                    style="{{ html_info.iframe_style }}"
                    onload="this.style.height=(Math.max(500, this.contentDocument.body.scrollHeight+45)) + 'px';"></iframe>
        {% endif %}
    {%- endcall %}
{% endmacro %}

{# Renders the report's text summary #}
{% macro summary_panel(summary, summary_height, idx) %}
    {% call render_panel("Summary", idx) -%}
        <div class="kb-app-report-summary" style="max-height: {{ summary_height }}">{{ summary }}</div>
    {%- endcall %}
{% endmacro %}

{# Renders links to individual report pages #}
{% macro report_links_panel(html_info, idx) %}
    {% call render_panel("Links", idx) -%}
        <ul class="kb-report-link-list">
        {% for link_info in html_info["links"] -%}
        <li>
            <a href="{{html_info.paths[loop.index0]}}" target="_blank">{{link_info.name}}</a>
            {% if link_info.description -%} - {{link_info.description}}{%- endif %}
        </li>
        {%- endfor %}
        </ul>
    {%- endcall %}
{% endmacro %}

{# Renders links to report files #}
{% macro report_file_links_panel(html_info, idx, narrative_link) %}
    {% call render_panel("Files", idx) -%}
        These are only available in the live Narrative: <a href="{{ narrative_link }}">{{ narrative_link }}</a>
        <ul class="kb-report-file-list">
        {% for link_info in html_info["file_links"] -%}
        <li>
            {{ link_info.name }}
            {% if link_info.description -%} - {{ link_info.description }}{%- endif %}
        </li>
        {%- endfor %}
        </ul>
    {%- endcall %}
{% endmacro %}

{#
 Renders the objects panel. Shows a table of the created objects, embedded in a panel.
 #}
{% macro objects_panel(objects, idx) %}
    {% call render_panel("Objects", idx) %}
        <div class="kb-app-result-objects">
            <table class="table table-striped table-bordered">
                <tr>
                    <th style="width:30%">Created Object Name</th>
                    <th style="width:20%">Type</th>
                    <th style="width:30%">Description</th>
                <tr>
                {% for o in objects %}
                    <tr>
                        <td>
                        {% if o.link %}
                        <a href="{{ o.link }}">{{o.name}}</a>
                        {% else %}
                        {{o.name}}
                        {% endif %}
                        </td>
                        <td>{{o.type}}</td>
                        <td>{{o.description}}</td>
                    </tr>
                {% endfor %}
            </table>
        </div>
    {% endcall %}
{% endmacro %}

{#
 Renders a KBase-ified Bootstrap panel with content from the caller.
 #}
{% macro render_panel(title, idx) -%}
    <div class="panel panel-default">
        <div class="panel-heading">
            <div class="panel-title">
                <span data-toggle="collapse" data-target="#app-report-objects-{{idx}}">{{title}}</span>
            </div>
        </div>
        <div id="app-report-objects-{{idx}}" class="panel-collapse collapse in">
            <div class="panel-body">
                {{ caller() }}
            </div>
        </div>
    </div>
{%- endmacro %}

{%- macro render_output_cell(metadata, narrative_link) -%}
    {% call render_kbase_cell(metadata,
                              metadata.attributes.title|default('Output Cell', True),
                              metadata.attributes.subtitle|default('', True)) %}
        <div class="kb-temp-output-cell">
            <div>
                The viewer for the output created by this App is available at the original Narrative here:
                <a href="{{ narrative_link }}">{{ narrative_link }}</a>
            </div>
        </div>
    {% endcall %}
{%- endmacro -%}

{%- macro render_data_cell(metadata, narrative_link) -%}
    {% call render_kbase_cell(metadata,
                              metadata.attributes.title|default('Data Cell', True),
                              metadata.attributes.subtitle|default('', True)) %}
        <div class="kb-temp-data-cell">
            <div>
                The viewer for the data in this Cell is available at the original Narrative here:
                <a href="{{ narrative_link }}">{{ narrative_link }}</a>
            </div>
        </div>
    {% endcall %}
{%- endmacro -%}

{%- macro render_app_cell(metadata, narrative_link) -%}
    {% call render_kbase_cell(metadata,
                              metadata.attributes.title|default('App Cell', True),
                              metadata.attributes.subtitle|default('', True)) %}
        <div class="kb-app-controls-wrapper">
            <div class="kb-app-status">
                {{ metadata.job.state }}
            </div>
            <div class="kb-app-controls">
                <button type="button" class="btn btn-primary kb-app-cell-btn app-view-toggle" data-idx={{metadata.idx}} data-view="config">
                    View Configure
                </button>
                <button type="button" class="btn btn-primary kb-app-cell-btn app-view-toggle selected" data-idx={{metadata.idx}} data-view="result">
                    Result
                </button>
            </div>
        </div>
        <div class="kb-app-body">
            <div id="app-{{ metadata.idx }}-config" class="kb-app-config" hidden>
            {% for b in [('input', 'Input Objects'), ('parameter', 'Parameters'), ('output', 'Output Objects')] %}
              {% if metadata.params[b[0]]|count > 0 %}
                <div class="kb-app-config-block">
                  <div class="kb-app-config-block-title">{{ b[1] }}</div>
                  {% for p in metadata.params[b[0]] %}
                    <div class="kb-app-param">
                      <div class="kb-app-param-name">{{ p.ui_name }}</div>
                      <div class="kb-app-param-field">
                      {% if p.value is not string and p.value is iterable %}
                        <table>
                        {% for v in p.value %}
                          <tr><td>{{ v }}</td></tr>
                        {% endfor %}
                        </table>
                      {% elif p.value or p.value == 0 %}
                          {{ p.value }}
                      {% else %}
                        &lt;Not set&gt;
                      {%- endif %}
                      </div>
                    </div>
                  {% endfor %}
                </div>
              {% endif %}
            {% endfor %}
            </div>

            <div id="app-{{metadata.idx}}-result" class="kb-app-results">
              {{ result_tab(metadata, narrative_link) }}
            </div>
        </div>
    {% endcall %}
{%- endmacro -%}

{%- macro render_kbase_cell(metadata, title, subtitle) -%}
    <div class="kb-cell-widget">
        <div style="display: flex">
            <div class="prompt input_prompt"></div>
            <div class="kb-app-cell">
                <div class="kb-app-header-container">
                    <div class="kb-app-header-title">
                        <div class="kb-app-header-icon">
                            {% if metadata.icon.type == 'image' %}
                            <div style="padding-top: 3px">
                                <img src="{{metadata.icon.icon}}" style="max-width: 50px; max-height: 50px; margin: 0"/>
                            </div>
                            {% elif metadata.icon.type == 'class' %}
                            <div>
                                <span class="fa-stack fa-2x">
                                    <span class="fa fa-{{ metadata.icon.shape }} fa-stack-2x" style="color: {{ metadata.icon.color }}"></span>
                                    <span class="fa fa-inverse fa-stack-1x {{ metadata.icon.icon }}"></span>
                                </span>
                            </div>
                            {% endif %}
                        </div>
                        <div class="kb-app-header-title-text">
                            <div class="title">
                                {% if metadata.external_link %}
                                <a href="{{ metadata.external_link }}">
                                {% endif %}

                                {{ title }}

                                {% if metadata.external_link %}
                                    <span class="fa fa-external-link"></span>
                                </a>
                                {% endif %}
                            </div>
                            <div class="subtitle">{{ subtitle }}</div>
                        </div>
                    </div>
                </div>
                <div class="kb-cell-body">
                    {{ caller() }}
                </div>
            </div>
        </div>
    </div>
{%- endmacro -%}

