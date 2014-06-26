json.array!(@jobs) do |job|
  json.extract! job, :id, :name, :job_type, :spec
  json.url job_url(job, format: :json)
end
