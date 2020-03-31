RegisterServerEvent('esx_jobs:getJobData')
AddEventHandler('esx_jobs:getJobData', function()
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    Jobs.UpdatePlayerJobData(xPlayer)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
        local players = GetPlayers()

        for _, playerId in pairs(players) do
            Jobs.LoadPlayerDataBySource(playerId)
        end
	end
end)

AddEventHandler('esx:setJob', function(source, job, lastJob)
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[lastJob.name] ~= nil and lastJob.name ~= job.name) then
        local xJob = Jobs.GetJobFromName(lastJob.name)

        xJob.removeMemberByIdentifier(xPlayer.identifier, function()
            local title = _U('job_removed_title', xPlayer.name)
            local message = _U('job_removed_description', xPlayer.name, xJob.label)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15158332)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and Jobs.Jobs[lastJob.name] == nil) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.addMemberByPlayer(xPlayer, function()
            local title = _U('job_added_title', xPlayer.name)
            local message = _U('job_added_description', xPlayer.name, xJob.label, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 3066993)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and job.grade ~= lastJob.grade) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.updateMemberByPlayer(xPlayer, function()
            local title = _U('job_updated_title', xPlayer.name)
            local message = _U('job_updated_description', xPlayer.name, lastJob.grade_label, lastJob.grade, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15105570)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif (xPlayer ~= nil) then
        Jobs.UpdatePlayerJobData(xPlayer)
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    Jobs.LoadPlayerDataBySource(playerId)
end)

RegisterServerEvent('esx_jobs:triggerServerCallback')
AddEventHandler('esx_jobs:triggerServerCallback', function(name, requestId, ...)
    local playerId = source

    Jobs.TriggerServerCallback(name, playerId, function(...)
        TriggerClientEvent('esx_jobs:serverCallback', playerId, requestId, ...)
    end, ...)
end)